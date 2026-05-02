const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
setGlobalOptions({ maxInstances: 10 });

// Triggered when a new SOS log is created under users/{uid}/sosLogs/{sosId}
exports.onSOSTriggered = onDocumentCreated(
  "users/{uid}/sosLogs/{sosId}",
  async (event) => {
    const uid = event.params.uid;
    const sosId = event.params.sosId;
    const sosData = event.data.data();

    logger.info(`SOS triggered by user ${uid}, sosId: ${sosId}`);

    const db = getFirestore();

    try {
      // 1. Get the user's profile
      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        logger.error(`User ${uid} not found`);
        return;
      }
      const userData = userDoc.data();
      const userName = userData.fullName || "A Nabd user";

      // 2. Get emergency settings
      const settingsDoc = await db
        .collection("users")
        .doc(uid)
        .collection("emergencySettings")
        .doc("emergencySettings")
        .get();

      const settings = settingsDoc.exists ? settingsDoc.data() : {};
      const sosEnabled = settings.sosEnabled ?? true;

      if (!sosEnabled) {
        logger.info(`SOS is disabled for user ${uid}`);
        return;
      }

      // 3. Get emergency contacts
      const contactsSnap = await db
        .collection("users")
        .doc(uid)
        .collection("emergencyContacts")
        .get();

      if (contactsSnap.empty) {
        logger.info(`No emergency contacts for user ${uid}`);
        return;
      }

      // 4. Build notification message
      const location = sosData.address || "Unknown location";
      const message = settings.defaultEmergencyMessage ||
        `${userName} has triggered an SOS alert and may need help!`;

      // 5. Send FCM notification to each contact's device token
      const notifications = [];
      for (const contactDoc of contactsSnap.docs) {
        const contact = contactDoc.data();
        const contactToken = contact.fcmToken;

        if (!contactToken) {
          logger.info(`Contact ${contactDoc.id} has no FCM token, skipping`);
          continue;
        }

        const fcmMessage = {
          token: contactToken,
          notification: {
            title: "🚨 SOS Alert",
            body: message,
          },
          data: {
            type: "sos",
            uid: uid,
            sosId: sosId,
            location: location,
            userName: userName,
          },
        };

        notifications.push(getMessaging().send(fcmMessage));
      }

      await Promise.all(notifications);

      // 6. Update SOS log to mark message as sent
      await db
        .collection("users")
        .doc(uid)
        .collection("sosLogs")
        .doc(sosId)
        .update({ messageSent: true });

      logger.info(`SOS notifications sent for user ${uid}`);
    } catch (error) {
      logger.error("Error processing SOS:", error);
    }
  }
);