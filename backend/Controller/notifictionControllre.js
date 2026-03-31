

const admin = require("firebase-admin");
const Token = require("../Model/notifictionModle");
const Notifiction = require("../Model/NotifictionModel");


// Firebase service account init
const serviceAccount = JSON.parse(
  Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, "base64").toString("utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const fcm = admin.messaging();

/**
 * Save FCM Token
 */
exports.saveToken = async (req, res) => {
  const { token, userId = "guest" } = req.body;

  if (!token) {
    return res.status(400).json({ ok: false, error: "Token required" });
  }

  try {
    const existing = await Token.findOne({ token });
    if (existing) {
      existing.userId = userId;
      existing.lastSeenAt = new Date();
      await existing.save();
    } else {
      await Token.create({ token, userId });
    }

    res.json({ ok: true, message: "Token saved successfully" });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

/**
 * Send Notification to:
 * - Specific token (if `token` provided)
 * - All tokens of a user (if `userId` provided)
 * - All tokens (if nothing provided)
 */
exports.sendNotification = async (req, res) => {
  const { token, userId, notification,  data = {} } = req.body;
console.log(notification,"kkkk")
  try {
    let tokens = [];

    if (token) {
      // Send to a single token
      tokens = [token];
    } else if (userId) {
      // Send to all tokens of a specific user
      const docs = await Token.find({ userId });
      tokens = docs.map((d) => d.token);
    } else {
      // Send to all saved tokens
      const docs = await Token.find({});
      tokens = docs.map((d) => d.token);
    }

    if (!tokens.length) {
      return res.status(404).json({ ok: false, error: "No tokens found" });
    }

    await Notifiction.create({
      title:notification.title,
      body:notification.body,
    })
    const message = {
      notification,
      data,
      tokens,
      webpush: {
        fcmOptions: {
          link: data.click_action || "https://saaranik-projects.netlify.app",
        },
        headers: { Urgency: "high" },
      },
    };

    // Send to multiple tokens
    const response = await fcm.sendEachForMulticast(message);

    // Remove invalid tokens
    const invalidTokens = [];
    response.responses.forEach((result, idx) => {
      if (result.error) {
        const code = result.error.code || result.error.errorInfo?.code;
        if (code === "messaging/registration-token-not-registered") {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    if (invalidTokens.length) {
      await Token.deleteMany({ token: { $in: invalidTokens } });
    }

    res.json({
      ok: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
      removedInvalid: invalidTokens.length,
      removedTokens: invalidTokens,
    });

  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};




// Get api data get notifiction 
function timeAgo(date) {
  const now = new Date();
  const diff = now - new Date(date); 
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 0) return days + " day" + (days > 1 ? "s" : "") + " ago";
  if (hours > 0) return hours + " hour" + (hours > 1 ? "s" : "") + " ago";
  if (minutes > 0) return minutes + " minute" + (minutes > 1 ? "s" : "") + " ago";
  return seconds + " second" + (seconds > 1 ? "s" : "") + " ago";
}

exports.getAllNotifications = async (req, res) => {
  try {
    const notifications = await Notifiction.find(
      { title: { $exists: true } },
      { title: 1, body: 1, createdAt: 1, updatedAt: 1 }
    ).sort({ createdAt: -1 });

    const formattedNotifications = notifications.map((n) => ({
      id: n._id,
      title: n.title,
      body: n.body,
      date: n.createdAt,
      ago: timeAgo(n.createdAt),
    }));

    res.json({ ok: true, notifications: formattedNotifications });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};