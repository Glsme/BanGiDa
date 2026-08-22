const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.onStoryCommentCreated = onDocumentCreated(
  {
    document: "images/{storyID}/comments/{commentID}",
    // Firestore가 asia-northeast3에 있으므로 함수도 같은 리전에 둔다.
    // 기본값(us-central1)으로 두면 트리거와 함수가 대륙을 넘어 오간다.
    region: "asia-northeast3",
  },
  async (event) => {
    const comment = event.data?.data();
    if (!comment) return;

    const { storyID } = event.params;
    const storySnapshot = await db.doc(`images/${storyID}`).get();
    const writerUID = storySnapshot.get("writerUUID");

    if (!writerUID || writerUID === comment.authorUID) return;

    const [userSnapshot, blockedSnapshot] = await Promise.all([
      db.doc(`users/${writerUID}`).get(),
      db.doc(`users/${writerUID}/blocks/${comment.authorUID}`).get(),
    ]);

    if (blockedSnapshot.exists) return;
    if (userSnapshot.get("commentNotificationEnabled") === false) return;

    const token = userSnapshot.get("fcmToken");
    if (!token) return;

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
    } catch (error) {
      if (
        error.code === "messaging/registration-token-not-registered" ||
        error.code === "messaging/invalid-registration-token"
      ) {
        await db.doc(`users/${writerUID}`).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
        return;
      }

      throw error;
    }
  }
);
