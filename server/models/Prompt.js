const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema(
  {
    author: {
      type: String,
      required: true,
    },
    authorAvatar: {
      type: String,
      default: '',
    },
    content: {
      type: String,
      required: true,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  {
    _id: false, // Exclude extra subdocument IDs for simpler JSON returns
    toJSON: {
      transform: (doc, ret) => {
        // Format to ISO string or fallback string matching Flutter expects
        ret.timestamp = ret.timestamp ? ret.timestamp.toISOString() : new Date().toISOString();
        return ret;
      },
    },
  }
);

const promptSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    prompt: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      default: '',
    },
    category: {
      type: String,
      default: 'All',
    },
    style: {
      type: String,
      default: 'Digital Art',
    },
    image: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
    },
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    ownerName: {
      type: String,
      required: true,
    },
    ownerAvatar: {
      type: String,
      default: '',
    },
    likes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    dislikes: {
      type: Number,
      default: 0,
    },
    saves: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    comments: [commentSchema],
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (doc, ret) => {
        // Match exactly what the Flutter JSON factory Expects
        ret.id = ret._id.toString();
        ret.author = ret.ownerName;
        ret.authorAvatar = ret.ownerAvatar;
        ret.likesCount = ret.likes ? ret.likes.length : 0;
        
        // Map arrays of references to plain string list arrays
        ret.likesList = ret.likes ? ret.likes.map(id => id.toString()) : [];
        ret.savesList = ret.saves ? ret.saves.map(id => id.toString()) : [];
        ret.commentsList = ret.comments || [];
        
        // Map numerical likes count to the likes field as Flutter expects
        ret.likes = ret.likesCount;
        
        // Format ISO timestamp
        ret.createdAt = ret.createdAt ? ret.createdAt.toISOString() : new Date().toISOString();
        
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: { virtuals: true },
  }
);

const Prompt = mongoose.model('Prompt', promptSchema);
module.exports = Prompt;
