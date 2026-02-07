# SKILLS.md

Best practices, guidelines, and skills for OpenClaw HQ agents across all domains: frontend, backend, marketing, SEO, security, and automation.

This document synthesizes knowledge from industry-leading agent skills repositories to ensure both Brain and Reviewer agents produce exceptional work.

---

## Table of Contents

1. [Frontend Development](#frontend-development)
2. [Backend & Database](#backend--database)
3. [Marketing & Growth](#marketing--growth)
4. [SEO & Content](#seo--content)
5. [Security & Best Practices](#security--best-practices)
6. [Automation & Browser](#automation--browser)
7. [Cross-Cutting Concerns](#cross-cutting-concerns)

---

## Frontend Development

### React & Next.js Performance (Vercel Standards)

**Priority: CRITICAL → HIGH → MEDIUM → LOW**

#### CRITICAL: Eliminate Request Waterfalls

Waterfalls are the #1 performance killer. Each sequential await adds full network latency.

**Incorrect:**
```typescript
async function Page() {
  const user = await fetchUser()
  const posts = await fetchPosts(user.id) // Waits for user first
  const comments = await fetchComments(posts[0].id) // Waits for posts
  return <Dashboard user={user} posts={posts} comments={comments} />
}
```

**Correct:**
```typescript
async function Page() {
  // Parallel fetching - all requests start immediately
  const [user, posts, comments] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchComments()
  ])
  return <Dashboard user={user} posts={posts} comments={comments} />
}
```

#### CRITICAL: Reduce Bundle Size

Use dynamic imports for code that isn't needed immediately.

**Incorrect:**
```typescript
import { HeavyChart } from 'heavy-chart-library' // Always loaded

export function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  return (
    <>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      {showChart && <HeavyChart data={data} />}
    </>
  )
}
```

**Correct:**
```typescript
import { lazy, Suspense } from 'react'

const HeavyChart = lazy(() => import('heavy-chart-library'))

export function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  return (
    <>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      {showChart && (
        <Suspense fallback={<Loading />}>
          <HeavyChart data={data} />
        </Suspense>
      )}
    </>
  )
}
```

#### HIGH: Optimize Package Imports

Use specific imports to enable tree-shaking.

**Incorrect:**
```typescript
import * as Icons from 'lucide-react' // Imports entire library
import { merge } from 'lodash' // Imports all of lodash
```

**Correct:**
```typescript
import { Home, Settings } from 'lucide-react' // Only imports needed icons
import merge from 'lodash/merge' // Only imports merge function
```

For Next.js 13.5+, use `optimizePackageImports` in next.config.js:
```javascript
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material', 'lodash']
  }
}
```

#### HIGH: Use React.cache() for Data Deduplication

**Incorrect:**
```typescript
// Multiple components fetch same data = multiple requests
async function UserProfile() {
  const user = await fetchUser(id)
  return <Profile user={user} />
}

async function UserPosts() {
  const user = await fetchUser(id) // Duplicate request!
  return <Posts userId={user.id} />
}
```

**Correct:**
```typescript
import { cache } from 'react'

const getUser = cache(async (id: string) => {
  return await fetchUser(id) // Cached within request
})

async function UserProfile() {
  const user = await getUser(id)
  return <Profile user={user} />
}

async function UserPosts() {
  const user = await getUser(id) // Returns cached value
  return <Posts userId={user.id} />
}
```

#### MEDIUM: Optimize State Management

Avoid expensive localStorage/sessionStorage reads.

**Incorrect:**
```typescript
function getTheme() {
  return localStorage.getItem('theme') ?? 'light' // Read on every call
}

function Component() {
  const theme = getTheme() // Called 10 times = 10 storage reads
  return <div className={theme}>...</div>
}
```

**Correct:**
```typescript
let cachedTheme: string | null = null

function getTheme() {
  if (cachedTheme === null) {
    cachedTheme = localStorage.getItem('theme') ?? 'light'
  }
  return cachedTheme
}
```

### Frontend Design (Anthropic Standards)

**Goal: Avoid generic "AI slop" aesthetics and create distinctive, production-grade interfaces.**

#### Design Process

1. **Understand Context:**
   - What problem does this interface solve?
   - Who uses it?
   - What technical constraints exist?

2. **Commit to a BOLD Aesthetic Direction:**
   - Brutally minimal
   - Maximalist chaos
   - Retro-futuristic
   - Organic/natural
   - Luxury/refined
   - Playful/toy-like
   - Editorial/magazine
   - Brutalist/raw
   - Art deco/geometric
   - Soft/pastel
   - Industrial/utilitarian

3. **Execute with Precision:**
   - **Typography:** Choose beautiful, unique fonts. AVOID generic fonts like Arial, Inter, Roboto, Space Grotesk
   - **Color:** Commit to a cohesive aesthetic. AVOID purple gradients on white backgrounds
   - **Layout:** Create unexpected, context-specific patterns
   - **Animation:** Match complexity to aesthetic vision
   - **Details:** Execute the vision well with attention to spacing, typography, subtle effects

**NEVER:**
- Use overused font families (Inter, Roboto, Arial, system fonts)
- Use cliched color schemes (purple gradients on white)
- Use predictable layouts and component patterns
- Create cookie-cutter designs without character
- Converge on common choices across generations

**Match implementation complexity to aesthetic:**
- Maximalist designs → elaborate code with extensive animations
- Minimalist designs → restraint, precision, careful spacing

### Web Design Guidelines (Vercel Standards)

#### Accessibility

**CRITICAL:**
- All interactive elements must have proper ARIA labels
- Color contrast must meet WCAG AA standards (4.5:1 for text)
- Keyboard navigation must work for all interactions
- Focus indicators must be visible and clear

**Incorrect:**
```html
<div onclick="submit()">Submit</div>
```

**Correct:**
```html
<button type="submit" aria-label="Submit form">Submit</button>
```

#### Performance

**Images:**
- Always use lazy loading: `<img loading="lazy">`
- Provide width/height to prevent layout shift
- Use responsive images with `srcset`
- Optimize format (WebP, AVIF when supported)

**Forms:**
- Proper label associations: `<label for="email">Email</label>`
- Input validation feedback must be clear
- Error messages must be specific and actionable

#### Mobile-First

- Start with mobile design, enhance for larger screens
- Touch targets minimum 44x44px
- Test on real devices, not just browser devtools

### Vue.js Best Practices

#### Reactivity Patterns

**Use ref() over reactive() for state:**

**Incorrect:**
```typescript
const state = reactive({
  count: 0,
  name: 'John'
})

// Loses reactivity when destructured
const { count } = state
```

**Correct:**
```typescript
const count = ref(0)
const name = ref('John')

// Maintains reactivity
const countValue = count.value
```

**Use .value in script, not in templates:**

**Incorrect (template):**
```vue
<template>
  <div>{{ count.value }}</div> <!-- WRONG in template -->
</template>
```

**Correct:**
```vue
<template>
  <div>{{ count }}</div> <!-- No .value in template -->
</template>

<script setup>
const count = ref(0)
// Use .value in script
console.log(count.value)
</script>
```

#### Composition API Patterns

**Create adaptable composables:**

```typescript
export interface UseHiddenOptions {
  hidden?: MaybeRef<boolean>
  initialHidden?: MaybeRefOrGetter<boolean>
  syncAria?: boolean
}

export function useHidden(
  target?: MaybeRefOrGetter<HTMLElement | null | undefined>,
  options: UseHiddenOptions = {}
) {
  const hidden = ref(toValue(options.initialHidden) ?? false)
  
  watch(hidden, (value) => {
    const el = toValue(target)
    if (el && options.syncAria) {
      el.setAttribute('aria-hidden', String(value))
    }
  })
  
  return { hidden }
}
```

**Use shallowRef for large objects:**
```typescript
// Heavy external library data
const editor = shallowRef(new CodeMirrorEditor())
```

### React Native & Expo

#### Tailwind Setup (Expo + NativeWind v5)

```bash
# Install dependencies
npx expo install tailwindcss@^4 nativewind@5.0.0-preview.2 \
  react-native-css@0.0.0-nightly.5ce6396 @tailwindcss/postcss \
  tailwind-merge clsx
```

**Metro config:**
```javascript
// metro.config.js
const { getDefaultConfig } = require("expo/metro-config")
const { withNativewind } = require("nativewind/metro")

const config = getDefaultConfig(__dirname)

module.exports = withNativewind(config, {
  inlineVariables: false,
  globalClassNamePolyfill: false
})
```

**Platform-specific styles:**
```css
@media ios {
  :root {
    --font-sans: system-ui;
    --font-rounded: ui-rounded;
  }
}

@media android {
  :root {
    --font-sans: normal;
    --font-rounded: normal;
  }
}
```

---

## Backend & Database

### Postgres Best Practices (Supabase Standards)

#### CRITICAL: Proper Indexing

Indexes are the #1 performance lever for databases.

**Incorrect:**
```sql
-- No index on foreign key
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL
);

-- Slow query on 1M rows
SELECT * FROM posts WHERE user_id = 123;
```

**Correct:**
```sql
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL
);

-- Index foreign keys
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- 10-100x faster on large tables
SELECT * FROM posts WHERE user_id = 123;
```

#### HIGH: Use Query Parameters (Prevent SQL Injection)

**Incorrect:**
```javascript
// SQL injection vulnerability!
const query = `SELECT * FROM users WHERE email = '${userInput}'`
db.query(query)
```

**Correct:**
```javascript
// Safe - parameterized query
const query = 'SELECT * FROM users WHERE email = $1'
db.query(query, [userInput])
```

#### HIGH: Pagination with Cursors

**Incorrect (offset pagination):**
```sql
-- Gets slower as offset increases
SELECT * FROM posts ORDER BY created_at DESC 
LIMIT 20 OFFSET 10000; -- Scans 10,020 rows!
```

**Correct (cursor pagination):**
```sql
-- Always fast, scans only needed rows
SELECT * FROM posts 
WHERE created_at < $1 
ORDER BY created_at DESC 
LIMIT 20;
```

#### MEDIUM: Efficient Data Types

Use appropriate column types to save space and improve performance.

**Incorrect:**
```sql
CREATE TABLE users (
  id VARCHAR(255), -- Wasteful for numeric IDs
  active VARCHAR(10), -- 'true' or 'false' as text
  created_at VARCHAR(50) -- Timestamp as text
);
```

**Correct:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY, -- or UUID
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Row Level Security (RLS)

Always enable RLS on tables with user data.

```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see their own posts
CREATE POLICY user_posts ON posts
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: users can update their own posts
CREATE POLICY user_posts_update ON posts
  FOR UPDATE
  USING (auth.uid() = user_id);
```

### API Design

#### RESTful Conventions

- `GET /api/users` - List users
- `GET /api/users/:id` - Get single user
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user (full)
- `PATCH /api/users/:id` - Update user (partial)
- `DELETE /api/users/:id` - Delete user

#### Error Responses

Return consistent error format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "notanemail"
    }
  }
}
```

#### Rate Limiting

Implement rate limiting on all public endpoints:

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
})

app.use('/api/', limiter)
```

---

## Marketing & Growth

### Conversion Rate Optimization (CRO)

#### Page Structure (Above the Fold)

1. **Clear Value Proposition** (5 seconds test)
   - What is it?
   - Who is it for?
   - What problem does it solve?

2. **Single Primary Call-to-Action (CTA)**
   - Make it obvious what you want users to do
   - Use action-oriented language ("Start Free Trial" not "Submit")

3. **Social Proof**
   - Customer logos, testimonials, or metrics
   - Position near CTA for maximum impact

#### Form Optimization

**Minimize friction:**
- Ask for minimum information needed
- Use single-column layouts
- Show progress for multi-step forms
- Provide inline validation feedback

**Incorrect:**
```html
<form>
  <input type="text" placeholder="First Name">
  <input type="text" placeholder="Last Name">
  <input type="text" placeholder="Email">
  <input type="text" placeholder="Company">
  <input type="text" placeholder="Job Title">
  <input type="text" placeholder="Phone">
  <button>Submit</button>
</form>
```

**Correct:**
```html
<form>
  <label for="email">Work Email</label>
  <input type="email" id="email" required>
  <!-- Only ask for what you need NOW -->
  <button>Start Free Trial</button>
</form>
```

### Copywriting Framework

#### Clarity > Cleverness

**Incorrect:**
```
Revolutionize Your Workflow Synergy
```

**Correct:**
```
Project Management Software for Remote Teams
```

#### Benefit-Driven Headlines

Focus on outcomes, not features.

**Incorrect:**
```
Advanced AI-Powered Analytics Dashboard
```

**Correct:**
```
See Which Features Drive Revenue (Without a Data Team)
```

#### AIDA Framework

1. **Attention**: Grab attention with compelling headline
2. **Interest**: Explain the problem you solve
3. **Desire**: Show transformation/outcome
4. **Action**: Clear CTA

### Marketing Psychology

#### Reciprocity
Offer value first (free tools, content, trials) to create obligation.

#### Social Proof
- Testimonials with photos and full names
- Customer count ("Join 10,000+ teams")
- Case studies with metrics

#### Scarcity & Urgency
- Limited-time offers (but be genuine)
- Stock indicators ("Only 3 seats left")
- Early-bird pricing

---

## SEO & Content

### Technical SEO

#### Title Tags

**Format:** Primary Keyword - Secondary Keyword | Brand

**Incorrect:**
```html
<title>Home</title>
```

**Correct:**
```html
<title>Project Management Software for Remote Teams | YourBrand</title>
```

Length: 50-60 characters (Google truncates ~60 chars)

#### Meta Descriptions

**Incorrect:**
```html
<meta name="description" content="We offer great services.">
```

**Correct:**
```html
<meta name="description" content="Manage remote teams with real-time collaboration, task tracking, and automated workflows. Start your free 14-day trial.">
```

Length: 150-160 characters

#### Schema Markup

Add structured data for rich snippets:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "YourApp",
  "applicationCategory": "BusinessApplication",
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "ratingCount": "1250"
  },
  "offers": {
    "@type": "Offer",
    "price": "29.00",
    "priceCurrency": "USD"
  }
}
</script>
```

#### Site Performance

Google uses Core Web Vitals as ranking factors:

- **LCP** (Largest Contentful Paint): < 2.5s
- **FID** (First Input Delay): < 100ms
- **CLS** (Cumulative Layout Shift): < 0.1

Optimize:
- Image sizes and formats
- Server response time
- Minimize render-blocking resources
- Lazy load below-the-fold content

### Content Strategy

#### Keyword Research

1. **Search Intent:**
   - Informational: "how to..."
   - Commercial: "best...", "top..."
   - Transactional: "buy...", "pricing..."

2. **Keyword Difficulty vs. Search Volume:**
   - Start with low-difficulty, medium-volume keywords
   - Build authority before targeting high-competition terms

#### Content Structure

**Use hierarchical headings:**
```html
<h1>Main Topic (only one per page)</h1>
  <h2>Primary Subtopic</h2>
    <h3>Supporting Detail</h3>
  <h2>Primary Subtopic</h2>
```

**Include:**
- Table of contents for long content (2000+ words)
- Internal links to related content
- External links to authoritative sources
- Images with descriptive alt text
- Clear CTAs at logical breakpoints

---

## Security & Best Practices

### Authentication & Authorization

#### Never Trust Client Input

**Incorrect:**
```javascript
// Client says they're an admin
app.post('/admin/delete-user', (req, res) => {
  if (req.body.isAdmin) { // NEVER trust this!
    deleteUser(req.body.userId)
  }
})
```

**Correct:**
```javascript
// Verify server-side
app.post('/admin/delete-user', authenticateToken, (req, res) => {
  // Check actual user role from database/JWT
  if (req.user.role === 'admin') {
    deleteUser(req.body.userId)
  } else {
    res.status(403).json({ error: 'Unauthorized' })
  }
})
```

#### Password Security

**Requirements:**
- Minimum 8 characters (12+ recommended)
- Hash with bcrypt (cost factor 10-12)
- NEVER store plaintext passwords
- NEVER log passwords

```javascript
const bcrypt = require('bcrypt')
const saltRounds = 12

// Hash password
const hashedPassword = await bcrypt.hash(password, saltRounds)

// Verify password
const match = await bcrypt.compare(password, hashedPassword)
```

#### JWT Best Practices

```javascript
// Short-lived access tokens
const accessToken = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.ACCESS_TOKEN_SECRET,
  { expiresIn: '15m' }
)

// Long-lived refresh tokens (stored securely)
const refreshToken = jwt.sign(
  { userId: user.id },
  process.env.REFRESH_TOKEN_SECRET,
  { expiresIn: '7d' }
)
```

### Environment Variables

**NEVER commit secrets to git:**

```env
# .env (add to .gitignore!)
DATABASE_URL=postgresql://user:password@localhost:5432/db
JWT_SECRET=your-super-secret-key
API_KEY=sk_live_...
```

**Use different values per environment:**
```
.env.local        # Local development
.env.production   # Production
```

### CORS Configuration

**Be specific, not permissive:**

**Incorrect:**
```javascript
app.use(cors({
  origin: '*' // Allows ANY origin!
}))
```

**Correct:**
```javascript
const allowedOrigins = [
  'https://yourdomain.com',
  'https://app.yourdomain.com'
]

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true
}))
```

### Input Validation

Always validate and sanitize user input:

```javascript
const { body, validationResult } = require('express-validator')

app.post('/users',
  [
    body('email').isEmail().normalizeEmail(),
    body('age').isInt({ min: 18, max: 120 }),
    body('username').trim().isLength({ min: 3, max: 20 })
      .matches(/^[a-zA-Z0-9_]+$/)
  ],
  (req, res) => {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() })
    }
    // Proceed with validated data
  }
)
```

---

## Automation & Browser

### Playwright / Browser Automation

#### Use Accessibility Selectors

**Incorrect:**
```javascript
await page.click('.btn-submit') // Brittle class selector
```

**Correct:**
```javascript
await page.getByRole('button', { name: 'Submit' }).click()
await page.getByLabel('Email').fill('user@example.com')
await page.getByText('Welcome').waitFor()
```

#### Wait for Conditions, Not Timeouts

**Incorrect:**
```javascript
await page.click('button')
await page.waitForTimeout(3000) // Flaky!
```

**Correct:**
```javascript
await page.click('button')
await page.waitForSelector('.success-message')
// Or
await page.waitForURL('**/dashboard')
```

#### Handle Errors Gracefully

```javascript
try {
  await page.goto('https://example.com', {
    waitUntil: 'networkidle',
    timeout: 30000
  })
} catch (error) {
  console.error('Navigation failed:', error)
  await page.screenshot({ path: 'error.png' })
  throw error
}
```

### Agent Browser (Vercel)

**Snapshot-based interaction:**

```bash
# Open page
agent-browser open https://example.com

# Get accessibility tree with refs
agent-browser snapshot -i

# Output shows:
# @e1 [input type="email"]
# @e2 [input type="password"]
# @e3 [button] "Sign In"

# Interact using refs
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3

# Wait for navigation
agent-browser wait --url "**/dashboard"
```

**Save and restore state:**

```bash
# Login once
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$USERNAME"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --load networkidle

# Save authenticated state
agent-browser state save auth.json

# Reuse in future sessions
agent-browser state load auth.json
agent-browser open https://app.example.com/dashboard
```

### n8n Workflows

#### Workflow Best Practices

1. **Error handling:**
   - Add error workflows for critical paths
   - Use retry logic with exponential backoff
   - Log errors with context

2. **Testing:**
   - Test workflows with edge cases
   - Use webhook test mode before going live
   - Monitor execution logs

3. **Organization:**
   - Name nodes descriptively
   - Group related nodes
   - Document complex logic in sticky notes
   - Version control workflow JSON files

---

## Cross-Cutting Concerns

### Code Quality

#### Naming Conventions

**Variables and Functions:**
- Use descriptive names: `getUserByEmail()` not `get()`
- Boolean variables: `isActive`, `hasPermission`, `canEdit`
- Constants: `MAX_RETRIES`, `API_BASE_URL`

**Files:**
- Components: `UserProfile.tsx` (PascalCase)
- Utilities: `formatDate.ts` (camelCase)
- Types: `user.types.ts` or `types.ts`

#### Comments

**Comment WHY, not WHAT:**

**Incorrect:**
```javascript
// Increment counter by 1
counter++
```

**Correct:**
```javascript
// Track page views for analytics
counter++

// Workaround for Safari bug where Date.now() 
// returns stale values in service workers
const timestamp = performance.now()
```

#### DRY Principle

Don't Repeat Yourself - extract reusable logic:

**Incorrect:**
```javascript
function formatUserDate(user) {
  return new Date(user.createdAt).toLocaleDateString('en-US')
}

function formatPostDate(post) {
  return new Date(post.publishedAt).toLocaleDateString('en-US')
}
```

**Correct:**
```javascript
function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('en-US')
}

// Use everywhere
formatDate(user.createdAt)
formatDate(post.publishedAt)
```

### Git Practices

#### Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```
feat(auth): add password reset functionality

fix(api): handle null response from user endpoint

docs(readme): update installation instructions
```

#### Branch Strategy

```
main           - Production code (protected)
develop        - Integration branch
feature/X      - New features
fix/X          - Bug fixes
hotfix/X       - Urgent production fixes
```

### Documentation

#### README.md Structure

```markdown
# Project Name

Brief description of what this project does.

## Features

- Feature 1
- Feature 2

## Installation

\`\`\`bash
npm install
\`\`\`

## Usage

\`\`\`javascript
import { something } from 'package'
\`\`\`

## Configuration

Environment variables:
- `API_KEY` - Your API key
- `DATABASE_URL` - Database connection string

## Contributing

See CONTRIBUTING.md

## License

MIT
```

#### Code Documentation

**For complex functions:**

```typescript
/**
 * Calculates the compound interest over a period
 * 
 * @param principal - Initial investment amount
 * @param rate - Annual interest rate (as decimal, e.g., 0.05 for 5%)
 * @param time - Number of years
 * @param frequency - Compounding frequency per year (default: 12)
 * @returns Total amount after interest
 * 
 * @example
 * calculateCompoundInterest(1000, 0.05, 10)
 * // Returns 1647.01
 */
function calculateCompoundInterest(
  principal: number,
  rate: number,
  time: number,
  frequency: number = 12
): number {
  return principal * Math.pow(1 + rate / frequency, frequency * time)
}
```

### Performance Monitoring

#### Metrics to Track

**Frontend:**
- Core Web Vitals (LCP, FID, CLS)
- Time to First Byte (TTFB)
- Total Blocking Time (TBT)
- Bundle size

**Backend:**
- Response time (p50, p95, p99)
- Error rate
- Request rate
- Database query time

**Business:**
- Conversion rate
- Bounce rate
- User engagement
- Retention

#### Tools

- **Frontend:** Vercel Analytics, Lighthouse, WebPageTest
- **Backend:** New Relic, DataDog, Sentry
- **Database:** pg_stat_statements, EXPLAIN ANALYZE
- **User Analytics:** Google Analytics 4, Mixpanel

---

## Enforcement

These skills and best practices are **binding** for both agents:

1. **Brain OpenClaw** must follow these guidelines when building
2. **Reviewer OpenClaw** must check for compliance during code review
3. **Felipe** makes final decisions on exceptions

### Priority Levels

- **CRITICAL**: Must be fixed before merge
- **HIGH**: Should be addressed in current PR or follow-up
- **MEDIUM**: Should be addressed when touching related code
- **LOW**: Nice-to-have improvements

### Review Checklist

Reviewer should verify:

- [ ] Performance best practices followed (eliminate waterfalls)
- [ ] Security vulnerabilities addressed (SQL injection, XSS, auth)
- [ ] Accessibility requirements met (ARIA, keyboard nav, contrast)
- [ ] Code quality standards maintained (naming, DRY, comments)
- [ ] Tests cover critical paths
- [ ] Documentation updated
- [ ] No secrets committed to git
- [ ] Database queries optimized with proper indexes

---

## Continuous Learning

This document should evolve as:

- New best practices emerge
- Tools and frameworks update
- We learn from production issues
- Industry standards change

Both agents should:
- Stay updated on framework changes
- Monitor performance metrics
- Learn from code review feedback
- Suggest improvements to this document

---

## References

This document synthesizes best practices from:

- **Vercel Agent Skills**: React/Next.js performance, web design guidelines
- **Anthropic Skills**: Frontend design, MCP builder
- **Supabase Agent Skills**: Postgres best practices
- **Corey Haines Marketing Skills**: CRO, copywriting, SEO, growth
- **Vue.js Agent Skills**: Vue 3 best practices, reactivity patterns
- **Expo Skills**: React Native, Tailwind CSS setup
- **Agent Browser**: Browser automation best practices

For detailed, domain-specific guidance, agents should consult the original skill repositories.

---

End of file.
