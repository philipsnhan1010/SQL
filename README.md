# TerpBuy
TerpBuy, a global business-to-consumer and business-to-business platform has a distribution facility in the city of Mumbai, India.
The company is looking for insights on different aspects of its customers, products, departments, and orders.

# About the Project
Part 1:
1. Load Terpbuy database.
2. Perform SQL scripting by answering some analysis questions.

- How many rows of data are stored for each table in the database? List the name of each table followed by the number of rows it has
SELECT TABLE_NAME AS 'Table Name', TABLE_ROWS AS 'Number of Rows in Table'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'terpbuy';

- List in alphabetical order all states supporting multiple customer segments
SELECT c.state AS 'State'
FROM customer c
GROUP BY c.state
HAVING COUNT(DISTINCT c.segment) >= 2
ORDER BY c.state;

...

Part 2:
1. Connect the database by Python.
2. Load data from the database to dataframes by queries and do the Visualization
3. Observation from the charts.

- Create a connection to the database:

conn = mysql.connector.connect(host='127.0.0.1', database='terpbuy', user='python', password='python')

- Retrieve the quantity of items sold by each department then sort by the department name. Load the result to df_department dataframe:

df_department = pd.read_sql("SELECT DISTINCT department_name AS 'Department_Name', SUM(quantity_sold) AS 'Total_Items_Sold'\
                             FROM order_line ol\
                                INNER JOIN product p ON ol.product_id = p.product_id\
                                INNER JOIN department d on p.department_id = d.department_id\
                             GROUP BY department_name\
                             ORDER BY department_name", conn)
df_department

- Bar chart to show all departments and the number of items each of them sold:

plt.figure(figsize=(18,8))
sns.set_theme(style="whitegrid")
visual_dept = sns.barplot(x="Department_Name",y="Total_Items_Sold", data=df_department)
visual_dept.axes.set_title("Product Department Sales Data",fontsize=26)
visual_dept.set_xlabel("Departments",fontsize=16)
visual_dept.set_ylabel("Number of Items Sold",fontsize=16)
visual_dept.tick_params(labelsize=13)
plt.show()

![image](https://user-images.githubusercontent.com/43742200/224870967-da98ef43-4cc0-4942-9ef3-bdee814966cd.png)


# Tech
- MySQL.
- Python: Numpy, Pandas, Matplotlib, Seaborn.
- Jupyter Notebook.

# Containing files
1. TerpBuy.sql: initial database script (create database, tables and insert data into tables).
2. TerpBuy_data_dictionary.jpg: database dictionary.
3. Terpbuy_Part_I.sql: part 1 SQL script
4. TerpBuy_Part2.ipynb: a Jupyter Notebook file for Part 2
