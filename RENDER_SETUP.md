# Render Setup - Configuration Files

## Files to Update/Create

### 1. Update `backend/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### 2. Create `backend/.npmrc`

```
legacy-peer-deps=true
production=true
```

### 3. Update `backend/package.json` - Add Build Scripts

```json
{
  "scripts": {
    "dev": "nodemon --exec ts-node src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "migrate": "node dist/migrate.js",
    "seed": "node dist/seed.js",
    "prebuild": "npm run lint || true",
    "prestart": "npm run build"
  }
}
```

### 4. Create `backend/src/migrate.ts`

```typescript
import pool from './config/database';

async function runMigrations() {
  const client = await pool.connect();
  try {
    console.log('Running migrations...');
    
    // Read and execute schema file
    const fs = require('fs');
    const schemaPath = '../database-schema.sql';
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    await client.query(schema);
    console.log('✓ Migrations completed');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations();
```

### 5. Create `backend/src/seed.ts`

```typescript
import pool from './config/database';

async function seedDatabase() {
  const client = await pool.connect();
  try {
    console.log('Seeding database...');
    
    // Create packages
    await client.query(`
      INSERT INTO packages (deposit_amount, monthly_profit_percentage, referral_bonus, description)
      VALUES 
        (50, 50, 25, 'Starter Package'),
        (100, 50, 50, 'Growth Package'),
        (150, 50, 75, 'Plus Package'),
        (200, 50, 100, 'Pro Package'),
        (250, 50, 125, 'Premium Package'),
        (300, 50, 150, 'Elite Package'),
        (400, 50, 200, 'Platinum Package'),
        (500, 50, 250, 'Diamond Package'),
        (750, 50, 375, 'Titanium Package'),
        (1000, 50, 500, 'Ultra Package')
      ON CONFLICT DO NOTHING
    `);
    
    // Create admin user
    const bcrypt = require('bcryptjs');
    const adminPassword = await bcrypt.hash('Admin@123', 10);
    const adminCode = 'ADMIN' + Math.random().toString(36).substr(2, 9).toUpperCase();
    
    await client.query(`
      INSERT INTO users (email, phone, full_name, password_hash, referral_code, kyc_verified)
      VALUES 
        ('admin@example.com', '254712345678', 'Admin User', $1, $2, true),
        ('user@example.com', '254700000000', 'Test User', $1, 'USER1', true)
      ON CONFLICT (email) DO NOTHING
    `, [adminPassword, adminCode]);
    
    // Create wallets
    await client.query(`
      INSERT INTO wallets (user_id, balance)
      SELECT id, 0 FROM users
      ON CONFLICT DO NOTHING
    `);
    
    console.log('✓ Database seeded successfully');
  } catch (error) {
    console.error('Seeding failed:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

seedDatabase();
```

### 6. Create `.env.production`

```env
NODE_ENV=production
PORT=5000
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_HOST=your_database_host
DB_PORT=5432
DB_NAME=big_jet_db
JWT_SECRET=your_jwt_secret_here
MPESA_CONSUMER_KEY=your_key
MPESA_CONSUMER_SECRET=your_secret
MPESA_SHORT_CODE=174379
MPESA_PASSKEY=your_passkey
MPESA_ENV=sandbox
MPESA_CALLBACK_URL=https://your-backend.onrender.com/api/mpesa/callback
LOG_LEVEL=info
NODE_OPTIONS=--max-old-space-size=512
```

### 7. Update `frontend/vite.config.ts`

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: '0.0.0.0',
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
      },
    },
  },
  define: {
    'process.env.VITE_API_URL': JSON.stringify(
      process.env.VITE_API_URL || 'http://localhost:5000/api'
    ),
  },
})
```

### 8. Create `frontend/.env.production`

```env
VITE_API_URL=https://your-backend.onrender.com/api
```

### 9. Create `.gitignore`

```
# Dependencies
node_modules
dist
build

# Environment
.env
.env.local
.env.*.local

# Logs
*.log
logs/

# OS
.DS_Store
.env.*.swp

# IDE
.vscode/
.idea/
*.swp

# Build
coverage/
.cache/
```

## Render Environment Variables

Set in Render Dashboard for **big-jet-backend**:

| Key | Value | Notes |
|-----|-------|-------|
| NODE_ENV | production | Required |
| PORT | 5000 | Auto-assigned by Render |
| DB_HOST | dpg-xxx.render.internal | From PostgreSQL URL |
| DB_USER | postgres | Default |
| DB_PASSWORD | xxxxx | From PostgreSQL URL |
| DB_NAME | big_jet_db | Default |
| DB_PORT | 5432 | Default |
| JWT_SECRET | (32 random chars) | Generate with `openssl rand -hex 32` |
| MPESA_CONSUMER_KEY | your_key | From M-Pesa |
| MPESA_CONSUMER_SECRET | your_secret | From M-Pesa |
| MPESA_SHORT_CODE | 174379 | Your business code |
| MPESA_PASSKEY | your_passkey | From M-Pesa |
| MPESA_ENV | sandbox | Change to production later |
| MPESA_CALLBACK_URL | https://big-jet-backend.onrender.com/api/mpesa/callback | Update with your URL |

Set for **big-jet-frontend**:

| Key | Value |
|-----|-------|
| VITE_API_URL | https://big-jet-backend.onrender.com/api |

## Build & Deploy Commands

**Backend Build Command:**
```
npm install --production=false && npm run build
```

**Backend Start Command:**
```
npm start
```

**Frontend Build Command:**
```
npm install && npm run build
```

## Health Check Endpoint

Render will ping `/health` to check if service is running.

Already configured in `backend-server.ts`:
```typescript
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});
```

## SSL Certificate

Render automatically provides:
- ✅ Free SSL/TLS certificate
- ✅ Auto-renewal
- ✅ HTTPS enforced by default
- ✅ No additional configuration needed

## Performance Optimization for Render

### Backend Optimization
```typescript
// Add connection pool limit
const pool = new Pool({
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Frontend Optimization
```typescript
// Already configured in vite.config.ts
build: {
  minify: 'terser',
  sourcemap: false,  // Disable in production
}
```

## Monitoring

### View Logs
```bash
# Render Dashboard → Service → Logs
# Filter by time
# Search for errors
```

### Check Metrics
```
Dashboard → Service → Metrics
- CPU Usage
- Memory Usage
- Disk Usage
- Request Count
```

## Troubleshooting Commands

### Check Node Version
```bash
node --version
# Should be 16+ on Render
```

### Test Database Connection
```bash
# In Render Shell
npm run migrate
# Should output: ✓ Migrations completed
```

### Check Environment Variables
```bash
# In Render Shell
env | grep DB_HOST
env | grep JWT_SECRET
# Should show values
```

## Zero-Downtime Deployment

Render automatically handles:
- ✅ Graceful shutdown (30 sec timeout)
- ✅ Health checks during deploy
- ✅ Rollback on failure
- ✅ Rolling updates

No additional configuration needed!

## Database Backups

Render automatically backs up PostgreSQL:
- Daily automated backups
- 30-day retention
- Manual backup option
- One-click restore

## Cost Optimization

### Reduce Costs:
1. Use Free tier for testing
2. Upgrade to Starter ($7/month) for production
3. Database: Starter tier ($15/month)
4. Frontend static site: Always free

### Monitor Usage:
- Check Metrics regularly
- Optimize slow queries
- Archive old data quarterly

---

**Ready to deploy!** Follow `RENDER_QUICK_DEPLOY.md` for step-by-step instructions.
