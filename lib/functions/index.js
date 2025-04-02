const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.resetTrips = functions.pubsub.schedule('every 5 minutes')  // Runs every 5 mins
  .timeZone('Asia/Kolkata') // Adjust the timezone if needed
  .onRun(async (context) => {
    const db = admin.firestore();

    try {
      const organizations = await db.collection("organisations").get();
      const batch = db.batch();

      for (const org of organizations.docs) {
        const driversRef = db.collection("organisations").doc(org.id).collection("drivers");
        const drivers = await driversRef.get();

        drivers.forEach(driver => {
          const driverDoc = driversRef.doc(driver.id);
          batch.update(driverDoc, { trips_remaining: 70 });
        });
      }

      await batch.commit();
      console.log("Successfully reset trips_remaining for all drivers.");
    } catch (error) {
      console.error("Error resetting trips:", error);
    }

    return null;
  });
