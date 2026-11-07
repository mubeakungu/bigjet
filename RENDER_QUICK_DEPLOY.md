# Quick Deploy to Render - Step by Step

## Prerequisites ✓
- Code on GitHub
- Render account (free: render.com)

## 5-Step Deployment

### Step 1: Push to GitHub (5 min)

```bash
cd big-jet-platform

# Initialize git
git init
git add .
git commit -m "Initial: Big Jet Investment Platform"

# Add remote
git remote add origin https://github.com/YOUR-USERNAME/big-jet-platform.git
git branch -M main
git push -u origin main
```

### Step 2: Create PostgreSQL Database (3 min)

1. Go to https://dashboard.render.com
2. Click **+ New** → **PostgreSQL**
3. Fill in:
   - Name: `big-jet-db`
   - Database: `big_jet_db`
   - User: `postgres`
   - Region: Pick one (e.g., Ohio)
4. Click **Create Database**
5. ⏳ Wait 2-3 minutes for database to be ready
6. **Copy** the **Internal Database URL** (looks like `postgresql://postgres:xxxx@dpg-xxx.internal/big_jet_db`)

### Step 3: Deploy Backend (5 min)

1. Click **+ New** → **Web Service**
2. Click **Connect GitHub**
3. Select `big-jet-platform` repository
4. Fill settings:
   - Name: `big-jet-backend`
   - Environment: `Node`
   - Region: **Same as database**
   - Branch: `main`
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Click **Environment** tab
6. Add these variables:

```
NODE_ENV                  = production
JWT_SECRET                = (generate random: openssl rand -hex 32)
DB_HOST                   = (from internal URL, extract hostname)
DB_USER                   = postgres
DB_PASSWORD               = (from internal URL, extract password)
DB_NAME                   = big_jet_db
DB_PORT                   = 5432
MPESA_CONSUMER_KEY        = (your M-Pesa key)
MPESA_CONSUMER_SECRET     = (your M-Pesa secret)
MPESA_SHORT_CODE          = 174379
MPESA_PASSKEY             = (your M-Pesa passkey)
MPESA_ENV                 = sandbox
MPESA_CALLBACK_URL        = https://big-jet-backend.onrender.com/api/mpesa/callback
```

7. Click **Create Web Service**
8. ⏳ Wait 5-10 minutes for backend to deploy

### Step 4: Deploy Frontend (3 min)

1. Click **+ New** → **Static Site**
2. Click **Connect GitHub**
3. Select `big-jet-platform` repository
4. Fill settings:
   - Name: `big-jet-frontend`
   - Root Directory: `frontend`
   - Build Command: `npm install && npm run build`
   - Publish Directory: `dist`
5. Click **Environment** tab
6. Add variable:

```
VITE_API_URL = https://big-jet-backend.onrender.com/api
```

7. Click **Create Static Site**
8. ⏳ Wait 3-5 minutes for frontend to deploy

### Step 5: Initialize Database (2 min)

1. Go to **big-jet-backend** service
2. Click **Shell** tab
3. Run:

```bash
npm run migrate
npm run seed
```

## ✅ You're Live!

- **Frontend**: https://big-jet-frontend.onrender.com
- **Backend API**: https://big-jet-backend.onrender.com/api
- **Test Login**:
  - Email: user@example.com
  - Password: User@123

## 🔧 Environment Variables Guide

### Database Connection String Breakdown
```
postgresql://postgres:PASSWORD@HOST/DATABASE

Extract:
- DB_HOST = HOST (e.g., dpg-abc123.render.internal)
- DB_USER = postgres
- DB_PASSWORD = PASSWORD (the long string)
- DB_NAME = big_jet_db
```

### JWT Secret Generation
```bash
# Generate random 32-character secret:
openssl rand -hex 32

# Or use Python:
python3 -c "import secrets; print(secrets.token_hex(32))"
```

## 🚨 Troubleshooting

### Backend Won't Deploy
```
Check logs: Click service → Logs tab
Common issues:
- Missing environment variables
- Database not ready yet
- Build command failed
```

### Frontend Can't Connect
```
Verify VITE_API_URL:
- Should be: https://big-jet-backend.onrender.com/api
- Check frontend service Environment tab
- May need to rebuild: Click Deploy button
```

### Database Connection Failed
```
Check:
1. DB_HOST has "internal" URL (not "external")
2. Database has finished initializing
3. Password is correct (copy from original URL)
```

## 📊 Monitoring

Go to each service dashboard:

1. **Logs** - View real-time application logs
2. **Metrics** - CPU, memory, disk usage
3. **Deploys** - Deployment history
4. **Settings** - Manage environment variables

## 🚀 Auto-Deploy

Push updates automatically deploy:

```bash
# Make changes
git add .
git commit -m "Add new feature"
git push origin main

# Render automatically:
# 1. Detects new commit
# 2. Builds new version
# 3. Deploys (zero downtime)
# Done! Check Logs tab
```

## 💰 Pricing

| Service | Free | Paid |
|---------|------|------|
| Backend | Spins down after 15 min idle | $7+/month |
| Frontend | Always free | N/A |
| Database | 90-day free trial | $15+/month |

For development: Use free tier (no cost!)

## 🎯 Next Steps

1. ✅ Deploy (done!)
2. Test all features
3. Add custom domain (optional)
4. Go live with M-Pesa (switch to production)
5. Scale as users grow

## 📚 Full Docs

See `RENDER_DEPLOYMENT.md` for:
- Custom domains
- Backup procedures
- Advanced configuration
- Performance optimization
- Production checklist

---

**Your platform is now live on Render! 🎉**

Any issues? Check the Logs tab first!
