const functions = require("firebase-functions");
const admin = require("firebase-admin");

fcmToken = await FirebaseMessaging.instance.getToken();

// Admin SDKでfireStoreを使う
admin.initializeApp(functions.config().firebase);

// データベースの参照を取得する
const fireStore = admin.firestore();

//CloudFunctionsに送る関数
exports.pushTalk = functions.https.onRequest((req, res) => {
  const message = {
    notification: {
      title: "近くにメモした内容",
      body: "内容は",
    },
    token: fcmToken,
  };

  admin
    .messaging()
    .send(message)
    .then((response) => {
      console.log("Successfully sent message:", response);
      res.status(200).send("Message sent successfully");
    })
    .catch((error) => {
      console.log("Error sending message:", error);
      res.status(500).send("Error sending message");
    });
});
