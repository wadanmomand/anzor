const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    passwordHash: {
      type: String,
      required: true,
    },
    avatar: {
      type: String,
      default: '',
    },
    coverBanner: {
      type: String,
      default: '',
    },
    bio: {
      type: String,
      default: '',
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
    followers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    following: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    savedPrompts: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Prompt',
      },
    ],
  },
  {
    timestamps: true, // Will populate 'createdAt' (mapping to 'joinDate')
    toJSON: {
      virtuals: true,
      transform: (doc, ret) => {
        // Exclude internal passwords and mongoose specific fields
        delete ret.passwordHash;
        ret.id = ret._id.toString();
        ret.joinDate = ret.createdAt;
        ret.followersCount = ret.followers ? ret.followers.length : 0;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: { virtuals: true },
  }
);

// Virtual for followers count
userSchema.virtual('followersCountVal').get(function () {
  return this.followers ? this.followers.length : 0;
});

// Virtual for following count
userSchema.virtual('followingCountVal').get(function () {
  return this.following ? this.following.length : 0;
});

const User = mongoose.model('User', userSchema);
module.exports = User;
