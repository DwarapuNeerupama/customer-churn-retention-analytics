# Retention Recommendations

Based on the churn drivers identified in EDA (Step 3), the business segments built in Step 4, the SQL revenue analysis (Step 6), and the ML model's churn probability scoring (Steps 7-9).

## Priority Order

| Priority | Segment / Group | Customers | Action Focus |
|---|---|---|---|
| 1 | Critical - High Value at Risk | 469 | Immediate, high-touch retention |
| 2 | Fiber optic + month-to-month + electronic check overlap | — | Structural/product-level fix |
| 3 | Medium Risk - Watch, ML-confirmed only | ~890 | Targeted, budget-efficient outreach |
| 4 | New customers (0-6 mo tenure) | — | Proactive onboarding, not reactive retention |
| Deprioritize | Low Risk - Stable, No internet service | 1,882 + — | Minimal spend, low expected return |

---

## 1. Prioritize "Critical - High Value at Risk" first

**469 customers, 70.58% churn rate.**

This segment combines the highest churn probability with the highest revenue per customer, making it the most expensive group to lose. The ML model independently confirms this is genuinely high-risk — 463 of 469 customers in this segment are also scored Critical by the model, so there's no ambiguity in prioritizing it.

- Proactive outreach (phone call or personalized offer, not a generic email) ahead of contract renewal
- Offer a discounted 1-year or 2-year contract, since month-to-month is the single strongest churn driver in the dataset

## 2. Target the three-factor risk profile

**Month-to-month contract + electronic check payment + fiber optic internet.**

Each factor independently shows the highest churn rate within its category:
- Month-to-month contracts: 42.71% churn
- Electronic check payment: 45.29% churn
- Fiber optic internet: 41.89% churn

Customers with all three overlapping make up the core of the Critical segments, and fiber optic alone accounts for $114.3K of the $139.13K total rule-based revenue at risk.

- Incentivize migration off electronic check to autopay (e.g., a small bill credit for switching) — this is a low-cost, high-leverage fix compared to renegotiating price or service
- Bundle a retention discount specifically for fiber optic customers still on month-to-month contracts, since this combination carries the most concentrated revenue exposure

## 3. Use the ML model to re-prioritize "Medium Risk - Watch"

**1,790 customers — the segment where the rule-based system and the ML model disagree most.**

The model scores exactly half of this segment (900 of 1,790) as Low risk. Treating the entire segment as equally worth watching wastes retention effort on customers who are statistically unlikely to leave.

- Split this segment using `churn_probability`: customers where the model agrees (probability ≥ 0.50) get retention outreach; customers where the model disagrees are left alone
- This is the most budget-efficient recommendation in this list — same spend, better-targeted list

## 4. Add tenure-based onboarding checkpoints

Churn is heavily concentrated in the 0-6 month tenure group, and tenure showed a large effect size (Cohen's d ≈ -0.85) in the Step 3 statistical testing.

- Structured check-ins at 30/90/180 days for new customers, especially those who also match the fiber optic + electronic check profile
- Treat this as a proactive/preventive track that runs in parallel to the reactive retention work above, not a replacement for it

## 5. Deprioritize low-risk segments

"Low Risk - Stable" (2.71% churn) and "No internet service" customers (7.40% churn, $2.3K revenue at risk) both show low churn and, in the no-internet case, minimal revenue exposure. Retention spend here has low expected return — reallocate that effort to priorities 1-3.

---

## Summary

| Segment | Churn Rate | Customers | Revenue at Risk | Recommended Action |
|---|---|---|---|---|
| Critical - High Value at Risk | 70.58% | 469 | High | Immediate outreach, contract incentive |
| Critical - At Risk | — | 1,031 | High | Payment method migration, contract offer |
| Medium Risk - Watch (ML-confirmed) | — | ~890 | Medium | Targeted outreach using churn probability |
| New customers (0-6 mo) | — | — | Growing | Proactive onboarding checkpoints |
| Low Risk - Stable | 2.71% | 1,882 | Low | No action needed |
| No internet service | 7.40% | — | $2.3K | No action needed |
