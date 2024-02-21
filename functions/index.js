const functions = require("firebase-functions");
const admin = require("firebase-admin");
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//

// Admin SDKでfireStoreを使う
admin.initializeApp(functions.config().firebase);

// データベースの参照を取得する
const fireStore = admin.firestore();

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

exports.getFirestore = functions.https.onRequest((req, res) => {
  // パラメータを取得
  const params = req.body;
  // パラメータから任意のdocument IDを取得する
  const documentId = params.documentId;

  if (documentId) {
    // 'test'というcollectionの中の任意のdocumentに格納されているデータを取得する
    const testRef = fireStore.collection("test");
    testRef
      .doc(documentId)
      .get()
      .then((doc) => {
        if (doc.exists) {
          res.status(200).send(doc.data());
        } else {
          res.status(200).send("document not found");
        }
      });
  } else {
    res.status(400).send({ errorMessaage: "document id not found" });
  }
});

// 位置情報を取得
exports.sendPushNotification = functions.firestore
  .collection("post")
  .onRequest(async (res, context) => {
    const userId = context.params.userId;
    const userData = res.after.data();

    // ユーザーの現在位置情報と登録された位置情報を比較し、一定の距離内に入った場合にプッシュ通知を送信するロジックを実装

    // FCMを使用してプッシュ通知を送信
    const message = {
      notification: {
        title: "近くに登録された位置情報があります",
        body: "お知らせ",
      },
      token: userData.fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log("Push notification sent successfully");
    } catch (error) {
      console.error("Error sending push notification:", error);
    }
  });
