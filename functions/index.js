const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

//fcmに送る関数
exports.pushTalk = functions
  .region("asia-northeast1")
  .https.onCall(async (req, res) => {
    const message = {
      notification: {
        title: "忘れてないですか？",
        body: "メモした位置の近くにいます。",
      },
      topic: "locationsMemo",
    };

    admin
      .messaging()
      .send(message)
      .then((response) => {
        console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.log("Error sending message:", error);
      });
  });
