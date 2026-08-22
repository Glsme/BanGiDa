const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

// 발송을 건너뛴 사유. Cloud Logging에서 reason으로 필터링해 원인을 구분한다.
const SkipReason = {
  EMPTY_EVENT: "empty_event",
  STORY_MISSING: "story_missing",
  SELF_COMMENT: "self_comment",
  BLOCKED: "blocked",
  NOTIFICATION_DISABLED: "notification_disabled",
  NO_TOKEN: "no_token",
};

exports.onStoryCommentCreated = onDocumentCreated(
  {
    document: "images/{storyID}/comments/{commentID}",
    // Firestore가 asia-northeast3에 있으므로 함수도 같은 리전에 둔다.
    // 기본값(us-central1)으로 두면 트리거와 함수가 대륙을 넘어 오간다.
    region: "asia-northeast3",
  },
  async (event) => {
    const { storyID, commentID } = event.params;

    // 댓글 본문과 FCM 토큰은 로그에 남기지 않는다. 사용자 콘텐츠와 자격 증명이
    // Cloud Logging에 축적되면 안 된다. 식별에 필요한 문서 ID까지만 기록한다.
    const context = { storyID, commentID };

    const comment = event.data?.data();
    if (!comment) {
      logger.warn("댓글 알림 건너뜀", { ...context, reason: SkipReason.EMPTY_EVENT });
      return;
    }

    const storySnapshot = await db.doc(`images/${storyID}`).get();
    const writerUID = storySnapshot.get("writerUUID");

    if (!writerUID) {
      logger.warn("댓글 알림 건너뜀", { ...context, reason: SkipReason.STORY_MISSING });
      return;
    }

    if (writerUID === comment.authorUID) {
      logger.info("댓글 알림 건너뜀", { ...context, reason: SkipReason.SELF_COMMENT });
      return;
    }

    const [userSnapshot, blockedSnapshot] = await Promise.all([
      db.doc(`users/${writerUID}`).get(),
      db.doc(`users/${writerUID}/blocks/${comment.authorUID}`).get(),
    ]);

    if (blockedSnapshot.exists) {
      logger.info("댓글 알림 건너뜀", { ...context, reason: SkipReason.BLOCKED });
      return;
    }

    if (userSnapshot.get("commentNotificationEnabled") === false) {
      logger.info("댓글 알림 건너뜀", { ...context, reason: SkipReason.NOTIFICATION_DISABLED });
      return;
    }

    const token = userSnapshot.get("fcmToken");
    if (!token) {
      logger.info("댓글 알림 건너뜀", { ...context, reason: SkipReason.NO_TOKEN });
      return;
    }

    const commentText = comment.text ?? "";
    const body = commentText.length > 40
      ? `${commentText.slice(0, 40)}…`
      : commentText;

    try {
      await admin.messaging().send({
        token,
        notification: {
          title: "새 댓글이 달렸어요",
          body: `${comment.authorNickname ?? "알 수 없는 사용자"}: ${body}`,
        },
        data: {
          type: "story_comment",
          storyID,
        },
      });

      logger.info("댓글 알림 발송", context);
    } catch (error) {
      if (
        error.code === "messaging/registration-token-not-registered" ||
        error.code === "messaging/invalid-registration-token"
      ) {
        await db.doc(`users/${writerUID}`).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });

        // 기기 앱 삭제·재설치 등으로 흔히 발생한다. 토큰을 지워 다음부터 헛발송을 막는다.
        logger.info("무효 토큰 삭제", { ...context, code: error.code });
        return;
      }

      logger.error("댓글 알림 발송 실패", { ...context, code: error.code });
      throw error;
    }
  }
);
