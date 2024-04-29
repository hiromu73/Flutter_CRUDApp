const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

//fcmに送る関数
exports.pushTalk = functions
  .region("asia-northeast1")
  .https.onCall(async (data, response) => {
    const title = data.title; // 通知のタイトル
    const body = data.body; // 通知の内容
    const token = data.token; // 送り先のトークン
    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        //androidの設定
        notification: {
          sound: "default",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        //iOSの設定
        payload: {
          aps: {
            sound: "default",
          },
        },
      },

      data: {},
      // topic: "locationsMemo",
      token: token,
    };
    pushToDevice(token, message);
    // admin
    //   .messaging()
    //   .send(message)
    //   .then((response) => {
    //     console.log("Successfully sent message:", response);
    //   })
    //   .catch((error) => {
    //     console.log("Error sending message:", error);
    //   });
  });

function pushToDevice(token, payload) {
  admin
    .messaging()
    .send(payload)
    .then((_pushResponse) => {
      return {
        text: token,
      };
    })
    .catch((error) => {
      throw new functions.https.HttpsError("unknown", error.message, error);
    });
}
