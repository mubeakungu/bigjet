# Deploy Big Jet Platform on Render

Render is a modern cloud platform perfect for deploying full-stack applications. This guide walks through deploying to Render.

## Prerequisites

- GitHub account with repository pushed
- Render account (https://render.com)
- Payment method on file (free tier available for testing)

## Step 1: Push Code to GitHub

```bash
git init
git add .
git commit -m "Initial commit: Big Jet Investment Platform"
git remote add origin https://github.com/yourusername/big-jet-platform.git
git branch -M main
git push -u origin main
```

## Step 2: Create PostgreSQL Database on Render

1. Go to https://dashboard.render.com
2. Click **New +** → **PostgreSQL**
3. Fill in details:
   - **Name**: `big-jet-db`
   - **Database**: `big_jet_db`
   - **User**: `postgres`
   - **Region**: Choose closest to you
   - **PostgreSQL Version**: 14
4. Click **Create Database**
5. Wait for creation (2-3 minutes)
6. Copy the **Internal Database URL** (you'll need this)

Example format:
```
postgresql://postgres:password@dpg-xxxxx.render.internal/big_jet_db
```

## Step 3: Create Backend Service

1. Click **New +** → **Web Service**
2. Connect GitHub repository:
   - Click **Connect GitHub account**
   - Select `big-jet-platform` repository
   - Click **Connect**
3. Configure:
   - **Name**: `big-jet-backend`
   - **Environment**: `Node`
   - **Region**: Same as database
   - **Branch**: `main`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free (or Starter $7/month)
4. Add Environment Variables:

```env
NODE_ENV=production
PORT=5000
DB_USER=postgres
DB_PASSWORD=<your_db_password>
DB_HOST=<internal_db_url_host>
DB_PORT=5432
DB_NAME=big_jet_db
JWT_SECRET=<generate_random_32_chars>
MPESA_CONSUMER_KEY=<your_mpesa_key>
MPESA_CONSUMER_SECRET=<your_mpesa_secret>
MPESA_SHORT_CODE=174379
MPESA_PASSKEY=<your_mpesa_passkey>
MPESA_ENV=sandbox
MPESA_CALLBACK_URL=https://big-jet-backend.onrender.com/api/mpesa/callback
```

5. Click **Create Web Service**
6. Wait for deployment (5-10 minutes)

## Step 4: Create Frontend Service

1. Click **New +** → **Static Site**
2. Connect GitHub:
   - Select `big-jet-platform` repository
3. Configure:
   - **Name**: `big-jet-frontend`
   - **Root Directory**: `frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
4. Add Environment Variables:

```env
VITE_API_URL=https://big-jet-backend.onrender.com/api
```

5. Click **Create Static Site**
6. Wait for deployment (3-5 minutes)

## Step 5: Initialize Database

After backend is deployed:

1. Go to backend service dashboard
2. Click **Shell** tab
3. Run migrations:

```bash
npm run migrate
npm run seed
```

## Step 6: Test Deployment

1. Go to frontend URL (https://big-jet-frontend.onrender.com)
2. Login with test account:
   - Email: `user@example.com`
   - Password: `User@123`
3. Test features:
   - Dashboard access
   - Create investment
   - Referral tracking

## Configuration Files for Render

### Create `render.yaml` (Optional - Infrastructure as Code)

```yaml
services:
  - type: web
    name: big-jet-backend
    env: node
    region: oregon
    plan: free
    buildCommand: npm install
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: DB_USER
        value: postgres
      - key: DB_NAME
        value: big_jet_db
      - key: MPESA_ENV
        value: sandbox

  - type: static_site
    name: big-jet-frontend
    staticPublishPath: frontend/dist
    buildCommand: cd frontend && npm install && npm run build
    envVars:
      - key: VITE_API_URL
        value: https://big-jet-backend.onrender.com/api

databases:
  - name: big-jet-db
    version: 14
    region: oregon
```

### Create `.renderignore`

```
node_modules
.git
.gitignore
README.md
docker-compose.yml
Dockerfile.*
.env.example
.DS_Store
```

## Environment Variables Reference

| Variable | Value | Notes |
|----------|-------|-------|
| NODE_ENV | production | Set to production |
| PORT | 5000 | Render assigns automatically |
| DB_* | See database | Internal connection string |
| JWT_SECRET | Random 32+ chars | Generate with: `openssl rand -hex 32` |
| MPESA_ENV | sandbox | Change to production later |
| MPESA_CALLBACK_URL | https://your-backend.onrender.com/api/mpesa/callback | Update with your URL |

## Domain Setup (Optional)

To use a custom domain:

1. Go to service settings
2. Click **Redirects/Rewrites**
3. Add custom domain (requires DNS changes)
4. Point CNAME to Render nameserver

Example DNS setup:
```
CNAME your-domain.com render.com
```

## Troubleshooting

### Build Fails
```bash
# Clear build cache in Render dashboard
# Go to service → Settings → Clear Build Cache
# Trigger new deploy
```

### Database Connection Error
```bash
# Check environment variables
# Verify DB_HOST uses internal database URL
# Test connection string locally first
```

### Frontend Can't Connect to API
```bash
# Verify VITE_API_URL points to correct backend URL
# Check CORS is enabled in backend
# Review browser console for exact error
```

### M-Pesa Callbacks Not Working
1. Verify callback URL in M-Pesa dashboard
2. Must be public HTTPS URL (not localhost)
3. Test with Postman: `POST https://your-backend.onrender.com/api/mpesa/callback`

## Monitoring & Logs

### View Logs
1. Go to service dashboard
2. Click **Logs** tab
3. Filter by time range
4. Search for errors

### Monitor Performance
1. Go to **Metrics** tab
2. Check CPU, Memory, Disk usage
3. Review request counts

## Upgrade Plans

- **Free Tier**: Spins down after 15 mins of inactivity
- **Starter**: $7/month - Always running, good for small projects
- **Standard**: $12/month+ - Better for production

Upgrade in service settings.

## Continuous Deployment

Render automatically deploys when you push to main branch:

```bash
# Make changes locally
git add .
git commit -m "Update feature"
git push origin main

# Render automatically:
# 1. Detects changes
# 2. Builds new version
# 3. Deploys to production
# 4. Zero downtime
```

## Going Live with M-Pesa

When ready for production:

1. Update `.env` with live M-Pesa credentials
2. Change `MPESA_ENV` to `production`
3. Update callback URL to production domain
4. Get SSL certificate (Render provides free SSL)
5. Enable HTTPS enforced redirect

## Backup & Security

### Backup Database
```bash
# Render PostgreSQL dashboard
# Click Backups tab
# View automatic daily backups
# Can restore anytime
```

### Environment Variables
- Never commit `.env` to GitHub
- Use `.env.example` as template
- Set all sensitive values in Render dashboard

### SSL/TLS
- Render provides free SSL automatically
- HTTPS enforced by default
- Auto-renewal

## Cost Estimate

| Service | Tier | Cost |
|---------|------|------|
| Backend | Starter | $7/month |
| Frontend | Free | $0 |
| Database | Starter | $15/month |
| **Total** | | **$22/month** |

Free tier available for testing (with limitations).

## Next Steps

1. ✅ Deploy to Render
2. Test all features
3. Set up custom domain
4. Configure M-Pesa live API
5. Launch publicly
6. Monitor performance
7. Scale as needed

## Support

- Render Docs: https://render.com/docs
- Render Status: https://status.render.com
- Help: https://render.com/support

Your platform is now live on Render! 🚀
