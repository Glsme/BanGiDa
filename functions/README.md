# BanGiDa Cloud Functions

댓글 생성 시 스토리 작성자에게 FCM 알림을 보낸다. 스토리 작성자 본인의 댓글, 작성자가 차단한 사용자의 댓글, 또는 댓글 알림을 끈 사용자는 발송 대상에서 제외한다.

## 배포 전 준비

1. Firebase CLI를 설치한다. 예: `npm install -g firebase-tools`
2. Firebase 프로젝트에 접근 가능한 계정으로 `firebase login`을 실행한다.
3. 레포지토리 루트에서 Firebase 프로젝트를 선택한다. `firebase use --add`를 한 번 실행하거나, 아래 명령에 `--project <PROJECT_ID>`를 추가한다.
4. 의존성을 설치한다. `cd functions && npm install && cd ..`

Cloud Functions 배포에 필요한 Blaze 요금제(D4)는 이미 적용되어 있다.

## 배포

레포지토리 루트에서 다음 명령을 실행한다.

```bash
firebase deploy --only functions
firebase deploy --only firestore:rules
```

두 번째 명령은 루트의 `firestore.rules`를 배포한다. 댓글 알림 Function은 댓글 1건마다 실행되고 Firestore 문서를 읽으므로, 무료 할당량을 넘는 사용량에 대비해 Firebase 콘솔의 예산 알림(budget alert)을 설정하는 것을 권장한다.
