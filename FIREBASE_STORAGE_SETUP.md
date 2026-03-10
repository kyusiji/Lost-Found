# Firebase Storage Setup Guide

This guide explains how to configure and manage Firebase Storage for your Lost & Found app to store profile pictures and item images.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Firebase Storage Rules](#firebase-storage-rules)
3. [Step-by-Step Setup](#step-by-step-setup)
4. [Managing Images](#managing-images)
5. [Firestore & Firestore Rules](#firestore--firestore-rules)
6. [Cost Monitoring](#cost-monitoring)

---

## 📖 Overview

Your app uses **Firebase Storage** to store images in two folders:

- **`profile_pictures/{userId}/`** - User profile photos (managed in `edit_profile_picture_screen.dart`)
- **`item_images/{userId}/`** - Lost/found item photos (managed in `report_item_screen.dart`)

### Folder Structure in Firebase Storage

```
bucket/
├── profile_pictures/
│   ├── user1_uid/
│   │   └── uuid-filename.jpg
│   ├── user2_uid/
│   │   └── uuid-filename.jpg
│
└── item_images/
    ├── user1_uid/
    │   ├── uuid-filename.jpg (item 1)
    │   └── uuid-filename.jpg (item 2)
    │
    └── user2_uid/
        ├── uuid-filename.jpg
```

---

## 🔐 Firebase Storage Rules

A `storage.rules` file has been created in your project root. This file defines **who can upload, read, and delete** images.

### Rules Breakdown

```
Profile Pictures:
- ✅ Anyone can READ (public)
- ✅ Only the owner (authenticated user) can WRITE or DELETE
- Path: /profile_pictures/{userId}/{fileName}

Item Images:
- ✅ Anyone can READ (so others can see lost/found items)
- ✅ Only the owner can WRITE or DELETE
- Path: /item_images/{userId}/{fileName}
```

### Deploying Storage Rules

To apply these rules to Firebase Storage:

#### Option 1: Using Firebase CLI (Recommended)

```bash
# At project root directory, run:
firebase deploy --only storage

# Output example:
# ✔ storage: rules updated successfully
```

#### Option 2: Manual via Firebase Console

1. Go to **Firebase Console** → Your Project → **Storage**
2. Click **Rules** tab
3. Replace the content with your `storage.rules` file content
4. Click **Publish**

---

## 🚀 Step-by-Step Setup

### Step 1: Deploy Storage Rules

```bash
# From project root
firebase deploy --only storage
```

### Step 2: Verify Your Firestore Rules

Ensure `firestore.rules` has proper settings:

```
# ✅ Current setup - Items are public readable
match /items/{document=**} {
  allow read: if true;                    # Anyone can see items
  allow write: if request.auth != null;   # Only authenticated users can report
}

# ✅ Users collection is private
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

### Step 3: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Step 4: Test Upload via App

1. Run your Flutter app
2. Go to **Edit Profile Picture**
3. Upload a photo → Should work without errors
4. Go to **Firebase Console** → **Storage** → Verify image appears

---

## 📸 Managing Images

### Current Implementation

#### Profile Picture Upload
**File**: `lib/screens/edit_profile_picture_screen.dart`

```dart
// Uploads to: /profile_pictures/{uid}/{uuid}.jpg
final photoUrl = await StorageService().uploadImage(
  File(pickedFile.path),
  'profile_pictures/$uid',
);

// Stores URL reference in Firestore: users/{uid}.photoUrl
await FirebaseFirestore.instance.collection('users').doc(uid).update({
  'photoUrl': photoUrl,
});
```

#### Item Image Upload
**File**: `lib/screens/report_item_screen.dart`

```dart
// Uploads to: /item_images/{uid}/{uuid}.jpg
final imageUrl = await StorageService().uploadImage(
  File(selectedImage.path),
  'item_images/$uid',
);

// Stores URL in Firestore: items/{docId}.imageUrl
await FirebaseFirestore.instance.collection('items').add({
  'imageUrl': imageUrl,
  // ... other fields
});
```

### Image Deletion

Both profile pictures and item images can be deleted:

```dart
// StorageService handles deletion
await StorageService().deleteImageFromUrl(imageUrl);
```

---

## 💾 Firestore & Storage Rules Working Together

### Data Flow

```
User Uploads Photo
        ↓
StorageService.uploadImage()
        ↓
Firebase Storage (rules check: is owner?)
        ↓
Returns download URL
        ↓
Save URL to Firestore
        ↓
Firestore Rules (check: is owner?)
        ↓
Document saved
```

### Firestore Schema

#### Users Collection
```json
{
  "uid": "user123",
  "firstName": "John",
  "surname": "Doe",
  "photoUrl": "https://firebasestorage.googleapis.com/.../profile_pictures/user123/uuid.jpg",
  "createdAt": 2024-01-15
}
```

#### Items Collection
```json
{
  "id": "item456",
  "type": "found",
  "title": "Blue Wallet",
  "imageUrl": "https://firebasestorage.googleapis.com/.../item_images/user123/uuid.jpg",
  "reporterUid": "user123",
  "location": "Library",
  "date": "2024-01-15",
  "status": "active"
}
```

---

## 💰 Cost Monitoring

### Firebase Storage Free Tier

- **5GB Storage** free per month
- **1GB Download/month** free
- **Unlimited Uploads**

### How to Monitor Costs

1. **Firebase Console** → **Storage** → **Files** tab
   - See total storage used
   - See individual file sizes

2. **Firebase Console** → **Usage** 
   - See download bandwidth used
   - Monitor quotas

### Cost Optimization Tips

✅ **Image Compression** (Already implemented)
```dart
await _picker.pickImage(
  imageQuality: 30,    // Compress to 30% quality
  maxWidth: 400,       // Max 400px width
);
```

✅ **Limit Image Size** → Prevents large uploads

✅ **Delete Old/Unused Images** → Frees up storage

✅ **Set TTL for Deleted Items** → Auto-cleanup
```dart
// Example: Auto-delete item images after 30 days if item is deleted
```

---

## 🔍 Track My Report Integration

The `track_my_report_screen.dart` now fetches user's own reports from Firestore:

```dart
// Queries items where reporterUid matches current user
Future<List<_TrackedItem>> _fetchUserReports(String itemType) async {
  final query = await FirebaseFirestore.instance
      .collection('items')
      .where('reporterUid', isEqualTo: uid)      // ← Filter by user
      .where('type', isEqualTo: itemType)        // ← 'found' or 'lost'
      .orderBy('createdAt', descending: true)
      .get();
}
```

**Features:**
- ✅ Shows only your own reports
- ✅ Filters by "Found" or "Lost"
- ✅ Displays item image from Firebase Storage
- ✅ Shows status (Active, Claimed, Handed Over)
- ✅ Delete button (coming soon)

---

## ⚠️ Important Security Notes

### What These Rules Protect Against

| Attack | Protected? | How |
|--------|-----------|-----|
| User A uploads to User B's folder | ✅ YES | `request.auth.uid == userId` |
| Anyone reads my profile pic | ❌ NO | Photos are public |
| User A deletes User B's items | ✅ YES | Only owner can delete |
| Anonymous user uploads images | ✅ YES | `request.auth != null` |

### Rule References

- `request.auth.uid` - Current user's ID from Firebase Auth
- `userId` - From storage path `/profile_pictures/{userId}/`
- `request.auth != null` - User is logged in

---

## 🆘 Troubleshooting

### Issue: "Permission denied" when uploading

**Solution**: 
1. Verify user is logged in: `AuthService().currentFirebaseUser != null`
2. Deploy storage rules: `firebase deploy --only storage`
3. Check Storage Rules allow write for authenticated users

### Issue: Image URL returns 403 Forbidden

**Solution**:
1. Check Storage Rules allow public read: `allow read: if true;`
2. Verify image actually exists in Firebase Storage
3. Try accessing URL in browser

### Issue: Profile picture not updating in app

**Solution**:
1. Check `photoUrl` is saved to Firestore (not `photoBase64`)
2. Verify image upload succeeded with no errors
3. Restart app to reload from Firestore

### Issue: Free tier quota exceeded

**Solution**:
1. Delete old/unused images from Storage
2. Lower image quality/size in image picker
3. Upgrade to paid plan if needed

---

## 📞 References

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Firebase CLI Commands](https://firebase.google.com/docs/cli)
- [Your Firestore Rules Reference](./firestore.rules)
- [Your Storage Rules Reference](./storage.rules)

---

## ✅ Checklist

- [ ] `storage.rules` file created ✓
- [ ] Storage rules deployed: `firebase deploy --only storage`
- [ ] Firestore rules deployed: `firebase deploy --only firestore:rules`
- [ ] Edit Profile Picture screen tested
- [ ] Report Item screen tested
- [ ] Track My Report screen shows user's items
- [ ] Images display correctly in app
- [ ] Firebase Console shows uploaded images in Storage
- [ ] Checked free tier usage limits

---

**Last Updated**: March 10, 2026
