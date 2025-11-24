# MCVenture Marketing Website

This directory contains the GitHub Pages marketing website for MCVenture.

## 🚀 Quick Setup

### 1. Push to GitHub

```bash
# Initialize git if not already done
cd /Users/bntf/Desktop/MCVenture
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with turn-by-turn navigation and marketing site"

# Create GitHub repo (go to github.com/new)
# Then push:
git remote add origin https://github.com/YOUR_USERNAME/mcventure.git
git branch -M main
git push -u origin main
```

### 2. Enable GitHub Pages

1. Go to your repo on GitHub
2. Click **Settings** → **Pages**
3. Under "Source", select:
   - Branch: `main`
   - Folder: `/docs`
4. Click **Save**

### 3. Wait 2-5 Minutes

Your site will be live at:
```
https://YOUR_USERNAME.github.io/mcventure/
```

## 📝 Update URLs

After your site is live, update these files:

### In App Store Connect:
- **Marketing URL**: `https://YOUR_USERNAME.github.io/mcventure/`
- **Support URL**: `https://YOUR_USERNAME.github.io/mcventure/support.html`
- **Privacy Policy URL**: `https://YOUR_USERNAME.github.io/mcventure/privacy.html`

### In docs/index.html:
- Replace `https://apps.apple.com/app/mcventure/id123456789` with your actual App Store URL (after submission)
- Replace `https://github.com/yourusername/mcventure` with your actual GitHub URL
- Replace `support@mcventure.app` with your actual email

### In docs/privacy.html:
- Replace email addresses with your actual emails

### In docs/support.html:
- Replace GitHub URL
- Replace email addresses

## 📄 Files Included

- `index.html` - Landing page with features and comparison
- `style.css` - Professional styling (mobile responsive)
- `privacy.html` - Privacy policy (GDPR compliant)
- `terms.html` - Terms of service
- `support.html` - Support page with FAQs
- `README.md` - This file

## ✅ What You Get

- ✅ Professional landing page
- ✅ App Store compliant privacy policy
- ✅ Terms of service
- ✅ Support page with FAQs
- ✅ Mobile responsive design
- ✅ SEO optimized
- ✅ FREE hosting on GitHub Pages

## 🎨 Customization

### Colors
Edit `style.css` lines 8-17 to change colors:
```css
:root {
    --primary-color: #FF6B35;  /* Orange */
    --secondary-color: #004E89; /* Blue */
    /* ... */
}
```

### Content
- Edit HTML files directly
- All text is easily editable
- Add screenshots by placing images in `/docs/images/`

## 📱 Preview Locally

Open `index.html` in your browser to preview:
```bash
open docs/index.html
```

Or use a local server:
```bash
cd docs
python3 -m http.server 8000
# Visit http://localhost:8000
```

## 🔗 Custom Domain (Optional)

To use a custom domain like `mcventure.app`:

1. Buy domain from Namecheap, GoDaddy, etc.
2. Add `CNAME` file in `/docs/`:
   ```
   mcventure.app
   ```
3. Configure DNS:
   - Add CNAME record pointing to `YOUR_USERNAME.github.io`
4. In GitHub Settings → Pages, add custom domain

## ✨ Features

- Beautiful hero section
- Feature showcase grid
- Competitor comparison table
- 8-language badges
- Call-to-action sections
- Legal pages
- FAQ support page
- Fully mobile responsive
- Fast loading
- SEO friendly

## 📧 Email Setup (Optional)

The site uses these email addresses:
- `support@mcventure.app`
- `privacy@mcventure.app`
- `legal@mcventure.app`

You can either:
1. Set up a custom domain and email
2. Use free email forwarding (ImprovMX, ForwardEmail)
3. Replace with your personal/Gmail address

## 🎉 You're Done!

Your marketing website is ready for:
- ✅ App Store submission URLs
- ✅ User support
- ✅ Privacy compliance
- ✅ Marketing campaigns

**Next Steps:**
1. Push to GitHub
2. Enable GitHub Pages
3. Update URLs in App Store Connect
4. Launch your app! 🚀
