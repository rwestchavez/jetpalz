const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnRequestChange = functions.firestore
    .document("requests/{requestId}")
    .onUpdate(async (change, context) => {
        console.log("wagwan");
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const ventureId = afterData["ventureId"];

        const ventureSnap = await admin.firestore().collection("ventures").doc(ventureId).get();

        // **Get the creator ID:**
        const ventureData = ventureSnap.data()
        const creatorRef = ventureData['creator']
        const creatorId = creatorRef.id;

        // Check if the status has changed
        if (beforeData['status'] !== afterData['status']) {
            let message = "";
            const userId = afterData['requesterId'];

            if (afterData['status'] === "accepted") {
                message = "Your request has been accepted.";
                console.log("This is working accepted");

            } else if (afterData['status'] === "rejected") { // only works for this. Need to use emulator for firestore. 
                message = "Your request has been rejected.";
                console.log("This is working rejected");
            }

            if (message && userId) {
                // Fetch the user document to get the FCM token
                const userDoc = await admin.firestore().collection("users").doc(userId).get();
                const userData = userDoc.data();

                if (userData && userData['fcm_token']) {
                    const payload = {
                        notification: {
                            title: "Request Status Update",
                            body: message,
                        },
                    };

                    // Send the notification to the device
                    try {
                        const response = await admin.messaging().send({
                            token: userData['fcm_token'],
                            notification: payload.notification,
                            data: payload.data, // Optional: add data payload if needed
                        });

                        console.log('Notification sent successfully:', response);
                    } catch (error) {
                        console.error('Error sending notification:', error);
                    }
                }
            }
        }

        return null;
    });

exports.sendNotificationOnRequestCreate = functions.firestore
    .document("requests/{requestId}")
    .onCreate(async (snap, context) => {
        console.log("on create");
        const requestData = snap.data();

        const ventureId = requestData["ventureId"]

        const ventureSnap = await admin.firestore().collection("ventures").doc(ventureId).get();

        // **Get the creator ID:**
        const ventureData = ventureSnap.data()
        const creatorRef = ventureData['creator']
        const creatorId = creatorRef.id;

        if (creatorId) {
            // Fetch the user document to get the FCM token
            const userDoc = await admin.firestore().collection("users").doc(creatorId).get();
            const userData = userDoc.data();

            if (userData && userData['fcm_token']) {
                const payload = {
                    notification: {
                        title: "Someone requested to join your Venture!",
                        body: "Click here to accept or reject ",
                    },
                };

                // Send the notification to the device
                try {
                    const response = await admin.messaging().send({
                        token: userData['fcm_token'],
                        notification: payload.notification,
                        data: payload.data, // Optional: add data payload if needed
                    });

                    console.log('Notification sent successfully:', response);
                } catch (error) {
                    console.error('Error sending notification:', error);
                }
            }
        }


        return null;
    });