# Customer Churn & Retention Analytics

A multi-tool analysis of customer churn for a telecom provider — using Python, SQL, machine learning, and Power BI to figure out who's leaving, why, how much revenue is at stake, and what to do about it.

## Business Question

Telecom companies lose a significant share of revenue every year to customer churn. This project asks four questions a retention team would actually need answered:

1. **Who is churning?** Which customer segments have the highest churn rates?
2. **Why are they churning?** What contract, service, and payment factors actually drive it?
3. **How much revenue is at risk?** Both from customers who've already left, and from customers likely to leave next?
4. **What should the business do about it?** Which segments should retention efforts prioritize first?

## Dataset

[Telco Customer Churn dataset](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) — 7,043 customers, 21 original features covering demographics, account information, and subscribed services.

## Approach

| Step | Tool | What it covers |
|---|---|---|
| 1-3 | Python (pandas) | Data inspection, cleaning, exploratory analysis |
| 4 | Python | Rule-based risk scoring and business segmentation |
| 5-6 | SQL (MySQL) | Data load and 15 business-question queries — consolidated into `telco_churn_analysis.sql` |
| 7-9 | Python (scikit-learn) | ML churn model, probability scoring, model-based revenue at risk |
| 10 | Power BI | 3-page interactive dashboard |
| 11 | — | Retention recommendations |

### Why both a rule-based score and an ML model?

The rule-based `risk_score` (Step 4) is transparent — anyone can read the scoring logic and understand exactly why a customer was flagged. The ML model (Step 7) captures churn risk across both current churners and customers who haven't churned yet, making it more useful for forward-looking retention planning, though less interpretable at a glance. Building both let me check one against the other: where they agree, that's a strong signal; where they disagree, that's worth a closer look. That comparison turned out to be one of the more useful findings in the whole project (see below).

## Key Findings

**Contract type, payment method, and internet service are the three strongest observed churn indicators**, each independently showing more than 40% churn in their highest-risk category. (These are strong statistical associations from EDA and the model's feature importances — the data shows correlation, not proven causation.)
- Month-to-month contracts: 42.71% churn (vs. 2.83% for two-year contracts)
- Electronic check payment: 45.29% churn (vs. ~15-19% for automatic payment methods)
- Fiber optic internet: 41.89% churn (vs. 18.96% DSL, 7.40% no internet)

**Revenue is heavily concentrated, not evenly spread.** Fiber optic customers alone account for $114.3K of the $139.13K total rule-based revenue at risk — over 80% of the dollar exposure sits in one service category, even though fiber optic isn't the majority of the customer base.

**The ML model estimates $211.7K in expected revenue at risk — 52% higher than the rule-based $139.13K figure.** The rule-based number only counts customers who have already churned. The model's figure also captures partial risk across customers who haven't left yet but have a meaningful probability of doing so, which is arguably a more complete picture of total exposure going forward.

**The rule-based segments and the ML model agree strongly at the extremes, and disagree meaningfully in the middle.** 463 of 469 "Critical – High Value at Risk" customers are also scored Critical by the model, and 1,867 of 1,882 "Low Risk – Stable" customers are scored Low — strong validation of the original segmentation logic. But in the "Medium Risk – Watch" segment, the model scores exactly half (900 of 1,790) as Low risk — suggesting the rule-based system may be over-flagging a chunk of this segment as worth watching when they're statistically unlikely to churn.

## Model Performance

Compared logistic regression against random forest for the churn prediction task:

| Model | ROC-AUC | Recall (Churn) | Accuracy |
|---|---:|---:|---:|
| Logistic Regression | 0.845 | 0.80 | 0.74 |
| Random Forest | 0.825 | 0.50 | 0.79 |

Went with **logistic regression** despite its lower accuracy, because recall on actual churners matters more for this business problem — missing a real churner costs more than a false alarm that triggers an unnecessary retention offer.

Used `cross_val_predict` (5-fold) rather than scoring the whole dataset with a single trained model, to avoid data leakage — scoring the training set with a model that already saw those customers' true outcomes would have produced overly optimistic probabilities for about 80% of the dataset.

## Dashboard

3-page Power BI dashboard:

1. **Executive Overview** — KPI summary, churn rate by business segment and contract type, revenue at risk by risk tier
2. **Churn Drivers** — payment method, internet service, and tenure breakdowns
3. **ML Model Insights** — rule-based vs. model-based revenue at risk comparison, and a segment-agreement matrix

![Churn Drivers page](./images/churn_drivers.png)
![ML Model Insights page](./images/ml_model_insights.png)

## Retention Recommendations

Full prioritized recommendations in [retention_recommendations.md](./retention_recommendations.md). Summary:

1. Prioritize the 469 "Critical – High Value at Risk" customers first — they represent the highest-priority combination of churn risk and customer value
2. Target the overlapping risk profile: month-to-month contract + electronic check + fiber optic
3. Use the ML model's churn probability to split the "Medium Risk – Watch" segment and avoid wasting retention budget on customers unlikely to churn
4. Add 30/90/180-day onboarding checkpoints for new customers, since churn is concentrated in the first 6 months
5. Deprioritize already-stable, low-risk segments to free up budget for the above

## Repo Structure

```
├── 01_data_inspection.ipynb
├── 02_data_cleaning.ipynb
├── 03_eda.ipynb
├── 04_customer_segments.ipynb
├── 07_09_ml_churn_model.ipynb
├── telco_churn_analysis.sql
├── customer_churn_PowerBI.pbix
├── retention_recommendations.md
├── README.md
└── images/
    ├── churn_drivers.png
    └── ml_model_insights.png
```

## Tools Used

Python (pandas, scikit-learn, matplotlib, seaborn) · SQL (MySQL) · Power BI · DAX
