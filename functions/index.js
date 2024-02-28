const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// データベースの参照を取得する
const fireStore = admin.firestore();

//fcmに送る関数
exports.pushTalk = functions.https.onCall(async (req, res) => {
  const message = {
    notification: {
      title: "忘れてないですか？",
      body: "近くにメモした内容",
    },
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
