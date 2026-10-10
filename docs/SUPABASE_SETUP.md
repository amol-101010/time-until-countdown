# Supabase setup for Dash cloud sync

One-time setup to get sync working. Takes about 5 minutes.

## 1. Create a project

1. Go to [supabase.com](https://supabase.com) and sign in (or create an account - the free tier is enough for this).
2. Click **New project**.
3. Pick an organization, name it (e.g. `dash`), set a database password (save it somewhere - you won't need it for the app, but you'll want it if you ever need direct DB access), and pick a region close to you.
4. Wait ~1-2 minutes for provisioning.

## 2. Run the schema

1. In your new project, open **SQL Editor** (left sidebar) → **New query**.
2. Open [`supabase/schema.sql`](../supabase/schema.sql) from this repo, copy its full contents, paste into the query editor.
3. Click **Run**. You should see "Success. No rows returned."
4. Sanity check: open **Table Editor** → you should see an `events` table with the columns from the schema.

## 3. Confirm email/password auth is enabled

It's on by default, but to double check: **Authentication** → **Providers** → **Email** should show as enabled. Leave "Confirm email" on or off as you prefer - off is simpler while testing (no email confirmation step), on is better before any real users sign up.

## 4. Get your project URL and anon key

**Project Settings** (gear icon) → **API**. You need two values:

- **Project URL** - looks like `https://xxxxxxxxxxxx.supabase.co`
- **anon / public key** - a long JWT string, labeled `anon` `public` (do **not** use the `service_role` key - that one bypasses row-level security and must never ship inside the app)

## 5. Give them to the app

Hand both values back and they'll be filled into `lib/config/supabase_config.dart` (added in Phase 2 of the current build). That file is not committed with real values in it - only placeholders - so treat your actual URL/key as something you paste in locally, not something to post publicly (the anon key is safe from a security standpoint since it's protected by the row-level security policy in `schema.sql`, but there's no reason to publish it either).

## What the RLS policy means in practice

`schema.sql`'s policy (`auth.uid() = user_id`) means: every row is only readable/writable by the user who owns it (matched by their auth user id). The app sets `user_id` to the signed-in user's id on every row it writes, and Postgres enforces the rest - even if the anon key leaked, nobody could read or write another user's events.
