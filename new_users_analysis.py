from google.cloud import bigquery
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Initialize BigQuery client
client = bigquery.Client()

# New Users Trend Analysis
query = """
SELECT 
    PARSE_DATE('%Y%m%d', event_date) as date,
    COUNT(DISTINCT user_pseudo_id) as new_users
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE event_name = 'first_open'
GROUP BY event_date
ORDER BY date;
"""

# Execute the query and load results into a pandas DataFrame
new_users = client.query(query).to_dataframe()

# Create visualization for new users trend
plt.figure(figsize=(12, 6))
sns.lineplot(data=new_users, x='date', y='new_users', marker='o', linewidth=2)
plt.title('New Users Trend Over Time')
plt.xlabel('Date')
plt.ylabel('Number of New Users')
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Print key metrics
print("\nKey New Users Metrics:")
print(f"Total New Users: {new_users['new_users'].sum()}")
print(f"Average Daily New Users: {new_users['new_users'].mean():.2f}")
print(f"Peak Daily New Users: {new_users['new_users'].max()}")
print(f"Growth Rate: {((new_users['new_users'].iloc[-1] - new_users['new_users'].iloc[0]) / new_users['new_users'].iloc[0] * 100):.2f}%") 