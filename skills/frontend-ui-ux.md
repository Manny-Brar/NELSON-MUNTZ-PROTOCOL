---
name: frontend-ui-ux
description: "Peak performance frontend, UI, and UX development skill for Nelson Muntz"
---

# Frontend UI/UX - Peak Performance Design Skill

## Purpose
Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics through intentional design decisions, proper component architecture, and attention to detail.

---

## THE ANTI-SLOP MANIFESTO

**Generic AI aesthetics to AVOID:**
- Inter, Roboto, Arial, system fonts (use distinctive typography)
- Purple gradients on white backgrounds (commit to a cohesive palette)
- Evenly-distributed, timid color schemes (dominant + sharp accents)
- Predictable layouts without visual hierarchy
- Missing micro-interactions and feedback states

**Instead, aim for:**
- Distinctive typography choices that match the brand
- Bold, committed color palettes with clear hierarchy
- Intentional whitespace and visual rhythm
- Polished micro-interactions at key moments
- Accessibility built-in, not bolted-on

---

## PHASE 1: DESIGN SYSTEM FOUNDATION

### Typography Selection

**Choose fonts with intention:**
```css
/* Example: Modern SaaS Dashboard */
--font-heading: 'Space Grotesk', sans-serif;  /* Bold, technical */
--font-body: 'Inter', sans-serif;              /* Readable body text */
--font-mono: 'JetBrains Mono', monospace;      /* Code/data */

/* Example: Creative/Portfolio */
--font-heading: 'Playfair Display', serif;     /* Elegant headlines */
--font-body: 'Source Sans Pro', sans-serif;    /* Clean body */
```

**Typography scale (use consistent ratios):**
```css
--text-xs: 0.75rem;    /* 12px - captions */
--text-sm: 0.875rem;   /* 14px - secondary */
--text-base: 1rem;     /* 16px - body */
--text-lg: 1.125rem;   /* 18px - emphasis */
--text-xl: 1.25rem;    /* 20px - subheadings */
--text-2xl: 1.5rem;    /* 24px - section titles */
--text-3xl: 1.875rem;  /* 30px - page titles */
--text-4xl: 2.25rem;   /* 36px - hero text */
```

### Color System

**Build a committed palette:**
```css
/* Primary: Your brand color - use boldly */
--primary-500: #6366f1;  /* Main actions */
--primary-600: #4f46e5;  /* Hover states */
--primary-700: #4338ca;  /* Active states */

/* Accent: Sharp contrast for attention */
--accent: #f59e0b;       /* CTAs, highlights */

/* Neutrals: Don't be afraid of contrast */
--gray-50: #fafafa;      /* Backgrounds */
--gray-900: #171717;     /* Primary text */

/* Semantic: Consistent meaning */
--success: #10b981;
--warning: #f59e0b;
--error: #ef4444;
--info: #3b82f6;
```

### Spacing System

**Use consistent spacing tokens:**
```css
--space-1: 0.25rem;   /* 4px - tight */
--space-2: 0.5rem;    /* 8px - compact */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px - default */
--space-6: 1.5rem;    /* 24px - comfortable */
--space-8: 2rem;      /* 32px - sections */
--space-12: 3rem;     /* 48px - major sections */
--space-16: 4rem;     /* 64px - hero spacing */
```

---

## PHASE 2: COMPONENT ARCHITECTURE

### Component Structure (React + TypeScript)

```typescript
// Component template with proper typing
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  children: React.ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  leftIcon,
  rightIcon,
  children,
  ...props
}: ButtonProps & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={cn(
        // Base styles
        'inline-flex items-center justify-center font-medium transition-all',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
        'disabled:opacity-50 disabled:pointer-events-none',
        // Variant styles
        variants[variant],
        // Size styles
        sizes[size],
      )}
      disabled={isLoading}
      {...props}
    >
      {isLoading && <Spinner className="mr-2 h-4 w-4 animate-spin" />}
      {!isLoading && leftIcon && <span className="mr-2">{leftIcon}</span>}
      {children}
      {rightIcon && <span className="ml-2">{rightIcon}</span>}
    </button>
  );
}
```

### State Handling Patterns

```typescript
// Loading, Error, Empty states - ALWAYS implement all three
function DataList() {
  const { data, isLoading, error } = useQuery(...);

  // Loading state
  if (isLoading) {
    return <Skeleton count={5} className="h-16 mb-2" />;
  }

  // Error state
  if (error) {
    return (
      <Alert variant="error">
        <AlertTitle>Failed to load data</AlertTitle>
        <AlertDescription>{error.message}</AlertDescription>
        <Button onClick={() => refetch()} className="mt-2">
          Try Again
        </Button>
      </Alert>
    );
  }

  // Empty state
  if (!data?.length) {
    return (
      <EmptyState
        icon={<InboxIcon />}
        title="No items yet"
        description="Create your first item to get started"
        action={<Button>Create Item</Button>}
      />
    );
  }

  // Success state
  return <List items={data} />;
}
```

---

## PHASE 3: MICRO-INTERACTIONS

### High-Impact Animation Moments

**1. Page Load - Staggered Reveals:**
```typescript
// Framer Motion staggered children
<motion.div
  initial="hidden"
  animate="visible"
  variants={{
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1 }
    }
  }}
>
  {items.map(item => (
    <motion.div
      key={item.id}
      variants={{
        hidden: { opacity: 0, y: 20 },
        visible: { opacity: 1, y: 0 }
      }}
    >
      {item.content}
    </motion.div>
  ))}
</motion.div>
```

**2. Hover States - Subtle Transforms:**
```css
.card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 40px rgba(0,0,0,0.12);
}
```

**3. Button Feedback:**
```css
.button {
  transition: all 0.15s ease;
}

.button:hover {
  transform: translateY(-1px);
}

.button:active {
  transform: translateY(0);
  scale: 0.98;
}
```

**4. Form Validation Feedback:**
```typescript
// Shake animation on error
<motion.div
  animate={hasError ? { x: [-10, 10, -10, 10, 0] } : {}}
  transition={{ duration: 0.4 }}
>
  <Input error={hasError} />
</motion.div>
```

### Animation Performance Rules

- Use CSS for simple transitions (hover, active)
- Use Framer Motion for complex sequences
- Prefer `transform` and `opacity` (GPU-accelerated)
- Avoid animating `width`, `height`, `top`, `left`
- Use `will-change` sparingly and only when needed

---

## PHASE 4: ACCESSIBILITY CHECKLIST

### Keyboard Navigation
```typescript
// Ensure all interactive elements are focusable
<button>Focusable by default</button>
<div role="button" tabIndex={0} onKeyDown={handleEnter}>
  Custom interactive element
</div>
```

### ARIA Labels
```typescript
// Icon-only buttons MUST have labels
<button aria-label="Close dialog">
  <XIcon />
</button>

// Loading states
<button aria-busy={isLoading} aria-live="polite">
  {isLoading ? 'Loading...' : 'Submit'}
</button>
```

### Color Contrast
```
Minimum ratios:
- Normal text: 4.5:1
- Large text (18px+): 3:1
- UI components: 3:1
```

### Focus Indicators
```css
/* Never remove focus outlines without replacement */
:focus-visible {
  outline: 2px solid var(--primary-500);
  outline-offset: 2px;
}
```

---

## PHASE 5: RESPONSIVE DESIGN

### Mobile-First Breakpoints
```css
/* Mobile first - no prefix */
.container { padding: 1rem; }

/* Tablet - sm: */
@media (min-width: 640px) {
  .container { padding: 1.5rem; }
}

/* Desktop - lg: */
@media (min-width: 1024px) {
  .container { padding: 2rem; }
}
```

### Touch Targets
```css
/* Minimum 44x44px for touch targets */
.touch-target {
  min-height: 44px;
  min-width: 44px;
  padding: 12px;
}
```

### Responsive Typography
```css
/* Fluid typography */
.heading {
  font-size: clamp(1.5rem, 4vw, 2.5rem);
}
```

---

## PHASE 6: PERFORMANCE OPTIMIZATION

### Image Optimization
```typescript
// Use next/image or similar for optimization
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // Above the fold
  placeholder="blur"
/>
```

### Code Splitting
```typescript
// Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart />
    </Suspense>
  );
}
```

### CSS Performance
```css
/* Avoid expensive selectors */
/* BAD */ .nav ul li a span { }
/* GOOD */ .nav-link-text { }

/* Use contain for complex components */
.card {
  contain: layout style paint;
}
```

---

## UI/UX DECISION CHECKLIST

Before implementing any UI feature:

```
[ ] Typography: Using intentional font choices (not defaults)?
[ ] Colors: Committed palette with clear hierarchy?
[ ] Spacing: Consistent token-based spacing?
[ ] States: Loading, error, empty states all handled?
[ ] Interactions: Hover, focus, active states defined?
[ ] Animations: High-impact moments identified?
[ ] Accessibility: ARIA labels, keyboard nav, contrast?
[ ] Responsive: Mobile-first with appropriate breakpoints?
[ ] Performance: Images optimized, code split where needed?
```

---

## ANTI-PATTERNS TO AVOID

### Layout Anti-Patterns
- ❌ Fixed widths on containers (use max-width)
- ❌ Pixel-based responsive breakpoints (use em/rem)
- ❌ Z-index wars (use stacking context system)

### Animation Anti-Patterns
- ❌ Animations on page load that block content
- ❌ Animations that can't be disabled (prefers-reduced-motion)
- ❌ Animating layout properties (width, height)

### Accessibility Anti-Patterns
- ❌ Removing focus outlines without replacement
- ❌ Color-only error indicators
- ❌ Auto-playing media without controls

### State Anti-Patterns
- ❌ No loading indicator during data fetch
- ❌ Generic "Something went wrong" errors
- ❌ Empty states with no guidance

---

## RESOURCES

- [The Shape of AI](https://www.shapeof.ai) - AI UX patterns
- [Carbon for AI](https://carbondesignsystem.com/guidelines/carbon-for-ai/) - IBM's AI design system
- [Figma Dev Mode MCP](https://www.figma.com/blog/design-systems-ai-mcp/) - Design system integration
- [patterns.dev AI UI Patterns](https://www.patterns.dev/react/ai-ui-patterns/) - React AI patterns

---

*Design with intention. Every pixel is a decision.*
