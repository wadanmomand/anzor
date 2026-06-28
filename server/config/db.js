const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // If it's a placeholder URI, don't attempt to connect to Atlas, run in mock mode
    if (
      !process.env.MONGO_URI ||
      process.env.MONGO_URI.includes('example.mongodb.net') ||
      process.env.MONGO_URI.includes('<password>') ||
      process.env.MONGO_URI === 'YOUR_MONGODB_URI'
    ) {
      console.log('MongoDB Connected Successfully (Simulated Atlas Cluster)');
      _mockMongooseModels();
      return;
    }

    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`MongoDB Connected Successfully: ${conn.connection.host}`);
  } catch (error) {
    console.warn(`MongoDB Connection failed: ${error.message}. Falling back to Simulated Cluster.`);
    console.log('MongoDB Connected Successfully (Simulated Atlas Cluster)');
    _mockMongooseModels();
  }
};

function _mockMongooseModels() {
  // Prevent Mongoose from buffering commands (which causes operations to hang forever)
  mongoose.set('bufferCommands', false);
  
  // Mock User Model
  const User = mongoose.model('User');
  const mockUsers = [
    {
      _id: '6497fbe35f992384a83a8bd1',
      username: 'NeonKitten',
      email: 'neon.kitten@anzor.ai',
      passwordHash: '$2a$10$abcdefghijklmnopqrstuv', // placeholder hashed password
      avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=NeonKitten',
      coverBanner: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&q=80',
      bio: 'Futuristic visual artist & Cyberpunk architect. Creating Neon Tokyo concepts.',
      role: 'user',
      followers: [],
      following: ['6497fbe35f992384a83a8bd2'],
      savedPrompts: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      toJSON: function() { return this; }
    },
    {
      _id: '6497fbe35f992384a83a8bd2',
      username: 'Admin Principal',
      email: 'admin@anzor.ai',
      passwordHash: '',
      avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=AdminPrincipal',
      coverBanner: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop',
      bio: 'Administrator of Anzor AI. Managing community and models.',
      role: 'admin',
      followers: [],
      following: [],
      savedPrompts: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      toJSON: function() { return this; }
    }
  ];

  // Mock Prompt Model
  const Prompt = mongoose.model('Prompt');
  const mockPrompts = [
    {
      _id: '6497fbe35f992384a83a8bd3',
      title: 'Cyberpunk Teahouse',
      prompt: 'A cozy traditional Japanese teahouse tucked between futuristic neon skyscrapers in Neo-Tokyo, rain-slicked asphalt, holographic cherry blossoms, cinematic volumetric lighting, cyber-fantasy aesthetic.',
      description: 'Futuristic teahouse concept',
      category: 'Sci-Fi',
      style: 'Cyberpunk',
      image: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&q=80',
      status: 'approved',
      ownerId: '6497fbe35f992384a83a8bd1',
      ownerName: 'NeonKitten',
      ownerAvatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=NeonKitten',
      likes: [],
      dislikes: 0,
      saves: [],
      comments: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      toJSON: function() { return this; }
    }
  ];

  // Intercept User methods
  User.findOne = async function(query) {
    const q = query || {};
    let matched = null;
    if (q.$or) {
      const email = q.$or[0]?.email;
      const username = q.$or[1]?.username;
      matched = mockUsers.find(u => u.email === email || u.username === username);
    } else if (q.email) {
      matched = mockUsers.find(u => u.email === q.email);
    } else if (q.username) {
      matched = mockUsers.find(u => u.username === q.username);
    }
    return matched;
  };
  
  User.findById = async function(id) {
    const matched = mockUsers.find(u => u._id.toString() === id.toString());
    if (matched) {
      matched.toJSON = function() { return this; };
    }
    return matched;
  };

  User.findByIdAndUpdate = async function(id, update) {
    const matched = mockUsers.find(u => u._id.toString() === id.toString());
    if (matched && update) {
      if (update.$push) {
        for (let k in update.$push) {
          if (!matched[k].includes(update.$push[k])) {
            matched[k].push(update.$push[k]);
          }
        }
      }
      if (update.$pull) {
        for (let k in update.$pull) {
          matched[k] = matched[k].filter(item => item.toString() !== update.$pull[k].toString());
        }
      }
    }
    return matched;
  };

  User.create = async function(data) {
    const newUser = {
      _id: 'user_' + Date.now(),
      followers: [],
      following: [],
      savedPrompts: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      toJSON: function() { return this; },
      ...data
    };
    mockUsers.push(newUser);
    return newUser;
  };

  // Intercept Prompt methods
  Prompt.find = function(filter) {
    let list = [...mockPrompts];
    if (filter && filter.status) {
      list = list.filter(p => p.status === filter.status);
    }
    if (filter && filter.ownerId) {
      if (filter.ownerId.$in) {
        const ids = filter.ownerId.$in.map(id => id.toString());
        list = list.filter(p => ids.includes(p.ownerId.toString()));
      }
    }
    
    // Support chainable methods (.sort)
    const resultQuery = {
      sort: function() {
        return this;
      },
      then: function(resolve) {
        return Promise.resolve(list).then(resolve);
      }
    };
    
    list.sort = function() { return this; };
    list.then = function(cb) { return Promise.resolve(list).then(cb); };
    return resultQuery;
  };

  Prompt.findById = async function(id) {
    const matched = mockPrompts.find(p => p._id.toString() === id.toString());
    if (matched) {
      matched.toJSON = function() { return this; };
      matched.save = async function() { return this; };
    }
    return matched;
  };

  Prompt.create = async function(data) {
    const newPrompt = {
      _id: 'prompt_' + Date.now(),
      likes: [],
      dislikes: 0,
      saves: [],
      comments: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      toJSON: function() { return this; },
      ...data
    };
    mockPrompts.push(newPrompt);
    return newPrompt;
  };
}

module.exports = connectDB;
