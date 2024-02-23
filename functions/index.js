const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Admin SDKでfireStoreを使う
admin.initializeApp(functions.config().firebase);

// データベースの参照を取得する
const fireStore = admin.firestore();

//CloudFunctionsに送る関数
exports.pushTalk = functions.region('asia-northeast1').https.onCall(async (data, _response) => {
  const title = data.title;  //通知のタイトル
  const body = data.body; //通知の内容
  const token = data.token; //送り先のトークン

  //通知の内容を作る処理
  const message = {
    notification: {
      title: title,
      body: body,
    },
    // アプリ内で使用できるデータ
    data: {
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
          badge: 1,
          sound: "default",
        },
      },
    },
    token: token,
  };
  pushToDevice(token, message);   //push通知を送る関数に内容を載せて実行
});

//push通知を送る関数
function pushToDevice(token, payload) {
  admin.messaging().send(payload)
    .then(_pushResponse => {
      return {
        text: token
      };
    })
    .catch(error => {
      throw new functions.https.HttpsError('unknown', error.message, error);
    });
}
