/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "chawe.ginbua@gmail.com",
    pass: "duyq sgcb exny uvgb"
  }
});

// 🔥 Firestore trigger
exports.sendEmailNotification = onDocumentCreated(
  "users/{userId}/notifications/{notifId}",
  async (event) => {

    const data = event.data.data();
    const userId = event.params.userId;

    const userDoc = await admin.firestore()
      .collection("users")
      .doc(userId)
      .get();

    const userEmail = userDoc.data().email;

    const mailOptions = {
      from: "Smart Study Planner",
      to: userEmail,
      subject: data.title,
      text: data.message
    };

    await transporter.sendMail(mailOptions);
  }
);