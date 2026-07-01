---
name: smtlib-encoding
description: Best practices for encoding verification problems in SMT-LIB. Use when writing SMT-LIB specifications, debugging solver performance, or working with solvers like CVC5 and Z3.
---

# SMT-LIB Verification Encoding Guide for Claude

This guide provides patterns and best practices for encoding verification problems in SMT-LIB.

---

## 1. Handling Out-of-Range Values: Sentinel vs Option Types

When representing "uninitialized" or "out-of-range" values (e.g., minimum of an empty set), choose between two approaches:

### Option Types (Type-Safe)

```smtlib
(declare-datatype IntOpt ( (Some (val Int)) (None) ))

(define-fun acc ((s IntOpt) (x Int)) IntOpt
  (ite ((_ is None) s)
       (Some x)
       (Some (ite (<= (val s) x) (val s) x))))
```

- ✅ Explicitly distinguishes "no value" from "has value"
- ❌ Requires datatype reasoning (slower for solvers)

### Sentinel Values (Solver-Friendly)

```smtlib
(declare-const _mx Int)

(define-fun acc ((s Int) (x Int)) Int
  (ite (= s _mx) x (ite (<= s x) s x)))
```

- ✅ Simple arithmetic constraints (faster for solvers)
- ❌ Must manually assert bounds for each variable

---

### Critical: Sentinel Encoding Pattern

**❌ WRONG:** Universal quantification is always UNSAT

```smtlib
(declare-const _mx Int)
(assert (forall ((y Int)) (> _mx y)))  ; Always unsat - useless!
```

**✅ CORRECT:** Declare variables and manually assert bounds

```smtlib
(declare-const _mx Int)
(declare-const y Int)
(assert (> _mx y))  ; sat - useful for reasoning!
```

**Why:** In SMT-LIB's integer theory, integers are unbounded. The `forall` assertion is a tautological contradiction. Instead, treat `_mx` as an uninterpreted constant representing a value "larger than any concrete integer in the problem domain."

**Encoding rules when using sentinels:**

1. For each concrete-valued variable: `(declare-const x Int)` then `(assert (< x _mx))`
2. For any data structure (lists, datatypes, etc.) holding concrete values, define an integrity predicate asserting bounds for all contained elements:

```smtlib
; Example: List of integers
(define-fun-rec IntList-integrity ((xs IntList)) Bool
  (match xs
    ((Nil true)
     ((Cons hd tl) (and (< hd _mx) (IntList-integrity tl))))))

; Example: Datatype with int fields
(define-fun State-integrity ((s State)) Bool
  (and (< (field1 s) _mx) (< (field2 s) _mx)))
```

3. Assert integrity for all structured inputs: `(assert (IntList-integrity input))`

---

### Decision Guide

| Approach     | Use When                                              |
| ------------ | ----------------------------------------------------- |
| **Option**   | Start here for clarity and type safety                |
| **Sentinel** | Switch if solver times out or performance is critical |

---

## 2. Avoid Recursive Functions in Specifications

Recursive functions force solvers to perform expensive inductive reasoning over unbounded data structures.

**Solver struggles with:**

- Recursive list operations (`append_list`, `remove`, `length`)
- Functions traversing entire data structures
- Deep pattern matching on inductive types
- Arithmetic operations combined with structural recursion

**Result:** Verification queries timeout or become intractable.

### Alternatives to Recursive Functions

When you need properties that would naturally be expressed recursively, consider:

**1. Quantifiers**

```smtlib
; Instead of recursive membership check
(define-fun-rec member ((x Int) (xs IntList)) Bool ...)

; Use quantifier
(assert (exists ((i Int)) (= (select arr i) x)))  ; for arrays
```

**2. Uninterpreted functions with axioms**

```smtlib
; Declare function without recursive definition
(declare-fun size (IntList) Int)

; Add axioms for specific properties
(assert (= (size Nil) 0))
(assert (forall ((x Int) (xs IntList)) 
  (= (size (Cons x xs)) (+ 1 (size xs)))))
```

**3. Built-in theory functions**

```smtlib
; Instead of custom list operations, use array theory
(declare-const arr (Array Int Int))
(assert (= (select arr 0) 5))
```

**4. Bounded expansion**

```smtlib
; Instead of computing full length, check bounded depth
(define-fun atleast3 ((xs IntList)) Bool
  (match xs
    ((Nil false)
     ((Cons h1 t1) (match t1
       ((Nil false)
        ((Cons h2 t2) (not ((_ is Nil) t2)))))))))
```

**Trade-offs:** Quantifiers can also cause performance issues. Prefer bounded structural checks when possible.

---

## 3. Helper Function Design Guidelines

### 1. Non-recursive When Possible

```smtlib
; ✅ GOOD: Direct definition
(define-fun prepend ((xs IntList) (x Int)) IntList
  (Cons x xs))

; ✅ GOOD: Simple match, no recursion
(define-fun nonempty ((xs IntList)) Bool
  (not ((_ is Nil) xs)))
```

### 2. Limit Recursion Depth

When recursion is necessary, bound the depth.

```smtlib
; ✅ GOOD: Only examines first 2 elements
(define-fun atleast2 ((xs IntList)) Bool
  (match xs
    ((Nil false)
     ((Cons h t) (not ((_ is Nil) t))))))

; ❌ BAD: Unbounded recursion
(define-fun-rec length ((xs IntList)) Int
  (match xs
    ((Nil 0)
     ((Cons hd tl) (+ 1 (length tl))))))
```

### 3. Avoid Mixing Recursion with Arithmetic

```smtlib
; ❌ BAD: Combines recursion + arithmetic
(define-fun-rec length ((xs IntList)) Int
  (match xs
    ((Nil 0)
     ((Cons hd tl) (+ 1 (length tl))))))

; ✅ GOOD: Pure structural check
(define-fun atleast3 ((xs IntList)) Bool
  (match xs
    ((Nil false)
     ((Cons h1 t1) (match t1
       ((Nil false)
        ((Cons h2 t2) (not ((_ is Nil) t2)))))))))
```

### 4. Use Closed-Form Definitions

Prefer direct pattern matching to recursive computation.

```smtlib
; ✅ GOOD: Closed form
(define-fun eq_IntOpt ((a IntOpt) (b IntOpt)) Bool
  (match a (
    ((None) ((_ is None) b))
    ((Some v) (and ((_ is Some) b) (= v (val b)))))))

; ✅ GOOD: Direct constructor
(define-fun empty_list () IntList Nil)
```

---

## 4. Iterative Debugging with Short Timeouts

When verification is slow or times out, use short timeouts to quickly identify bottlenecks rather than waiting for long failures.

### Strategy: Start Fast, Expand Gradually

**❌ WRONG: Wait for long timeout**

```bash
# Wait 5 minutes to discover it fails
cvc5 problem.smt2  # Times out after 300 seconds
```

**✅ CORRECT: Use short timeout to find problem quickly**

```smtlib
(set-option :tlimit-per 5000)  ; 5 seconds per check-sat

(push)
(echo "Block A")
(assert block-A-constraints)
(check-sat)  ; Quick feedback: does this timeout?
(pop)

(push)
(echo "Block B")
(assert block-B-constraints)
(check-sat)  ; Quick feedback: does this timeout?
(pop)
```

### Bisection Pattern

Once you identify a slow block, comment out parts to find the bottleneck:

```smtlib
(push)
(echo "Testing Block R - attempt 1")
(assert constraint-1)
(assert constraint-2)
; (assert constraint-3)  ; Comment out to test without this
; (assert constraint-4)
(check-sat)  ; Does it pass now?
(pop)

; If it passes, uncomment one at a time:
(push)
(echo "Testing Block R - attempt 2")
(assert constraint-1)
(assert constraint-2)
(assert constraint-3)  ; Add back
; (assert constraint-4) ; Keep this out
(check-sat)  ; Still fast? Problem is constraint-4
(pop)
```

### Workflow

1. **Set short timeout** (5-10 seconds per check)
2. **Run all verification blocks** - identify which timeout
3. **Comment out half the constraints** in slow blocks
4. **Binary search** to isolate the problematic constraint
5. **Simplify the problematic constraint** (weaken invariants, remove recursive calls)
6. **Gradually restore full problem** once base case works

### Timeout Options

**Per-check timeout** (recommended for debugging):

```smtlib
(set-option :tlimit-per 5000)  ; Milliseconds per check-sat
```

**Global timeout** (less useful for debugging):

```smtlib
(set-option :tlimit 30000)  ; Total time for entire file
```

**Why per-check is better:** You get feedback on which specific `check-sat` is slow, not just "somewhere in this 500-line file."

### Try Different Solvers

If one solver times out, try another (CVC5, Z3, etc.). Solvers have different strengths - a problem hard for one may be easy for another.
