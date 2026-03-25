# Contributing to Moonveil

Welcome! Thanks for your interest in contributing to **Moonveil** — a modern, customizable Hyprland + QuickShell environment.

This guide will help you get started quickly.

---

##  Project Structure

```
moonveil/
├── .config/
│   └── quickshell/
│       └── Crescentshell/   # UI (bar, notch, dashboard)
├── dots/
│   └── .config/             # System configs
├── installer/               # Install scripts
└── .local/
```

---

## 🌿 Branching Strategy

Moonveil uses the following branches:

- `master` → Stable (**DO NOT commit directly**)
- `playground` → Development (**USE THIS**)

👉 All contributions must target **playground**

---

## 🚀 Getting Started

### 1. Fork the Repository

Click **Fork** on GitHub.

---

### 2. Clone Your Fork

```bash
git clone https://github.com/your-username/moonveil.git
cd moonveil
```

---

### 3. Create a New Branch

```bash
git checkout -b feature/your-feature-name
```

---

### 4. Workflow

```bash
git add .
git commit -m "feat: your change"
git push origin feature/your-feature-name
```

Then open a **Pull Request → target `playground`**

---

## Commit Style

Use consistent commit messages:

- `feat:` → New feature  
- `fix:` → Bug fix  
- `ui:` → UI improvement  
- `docs:` → Documentation  
- `refactor:` → Code cleanup  

---

## Pull Request Rules

- Target **`playground`**
- Keep PRs **focused and small**
- Add **screenshots** for UI changes
- Do **not break existing features**

---

##  What You Can Work On

Moonveil is not a strict project.

You’re free to build anything.

- Add your own features
- Try your own ideas
- Change UI in your style
- Experiment with new concepts

 Make multiple PRs if you want like seriously.

Small changes, big features, random ideas everything is welcome.

---

### No limits

You don’t have to follow a fixed list.

If you think:
> “this would be cool”

Just build it and open a PR.

---

## Style

- Don’t wait for permission
- Don’t overthink it
- Just build and submit

Even if it’s not perfect we can refine it together.

---

### Core Features to work on 
- Dashboard UI
- Emoji Picker
- Clipboard Manager

---

### UI / UX
- Settings app refinement
- Improve spacing & layout
- Better animations

---

### Improvements
- Performance optimizations
- Installer improvements
- Code cleanup

---

## Issues

- feel free to **open your issue**.

---

## 💬 Need Help?

Open an issue no problem at all.

---

## Rules

- ❌ Don’t push to `master`
- ✅ Keep code clean
- ✅ Follow project style

---

## Final Note

Moonveil is evolving fast.

Even small contributions matter.

Thanks for being part of it :D
