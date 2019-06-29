-- 1. Create a view called 'old_books' that lists the author's first name and last name, book title and edition for every book published before 1990.
CREATE VIEW old_books(first_name, last_name, book_title, edition)
AS SELECT authors.first_name, authors.last_name, books.title, editions.edition
FROM authors, books, editions
WHERE authors.author_id = books.author_id AND
books.book_id = editions.book_id AND
date_part('Year', publication)::INTEGER < 1990;

-- 2. Create a view called 'programming_or_perl' that Returns a list of the titles of all books with the words 'Programming' or 'Perl' in the title.
CREATE VIEW programming_or_perl(book_title)
AS SELECT title FROM books
WHERE (title LIKE '%Programming%' OR title LIKE '%Perl%');

-- 3. Create a view called 'retail_price_hike' that returns the ISBN , retail price and a final column that contains the retail price increased by 25%.
CREATE VIEW retail_price_hike(ISBN, retail_price, increased_price)
AS SELECT isbn, retail, ROUND((1.25*retail),2)
FROM stock;


-- 4. Create a view called 'book_summary' which returns the first name, last name of each book author along with the books title and subject.
CREATE VIEW book_summary(author_first_name, author_last_name, book_title, subject)
AS SELECT authors.first_name, authors.last_name, books.title, subjects.subject
FROM authors, books, subjects
WHERE authors.author_id = books.author_id AND
books.subject_id = subjects.subject_id;

-- 5. Create a view called 'value_summary' that returns the total cost value (cost*stock) and total retail value (retail*stock) across all stock.
CREATE VIEW value_summary(total_stock_cost, total_retail_cost)
AS SELECT SUM(cost*stock), SUM(retail*stock)
FROM stock;

--6. Create a view called 'profits_by_isbn' that returns the book title, isbn for each book along with the difference between the sum of the cost and retail values across all shipments for each book. The results should be grouped by book title and isbn.
CREATE VIEW profits_by_isbn(book_title, edition_isbn, total_profit)
AS SELECT books.title, editions.isbn, SUM(stock.retail-stock.cost)
FROM books, editions, stock, shipments
WHERE books.book_id = editions.book_id AND
editions.isbn = stock.isbn AND
stock.isbn = shipments.isbn
GROUP BY books.title, editions.isbn;

--7. Create a view called 'sole_python_author' that returns the first name and last name of any author (If one exists) who publishes all of the books with the text 'Python' in the title (Note the author may publish other books as well but if there are multiple authors of books with 'Python' in the title, no records should be returned). 
CREATE VIEW sole_python_author(author_first_name, author_last_name)
-- Retrieve an authors first name and last name from the returning values of a nested select statement
-- The first nested select statement finds the authors ID, first name and last name such that the authors and books table relate and
-- the word 'Python' is somewhere in the title. The query is grouped by author ID, first name and last name which returns a row.
-- To check that the author has only written books with 'Python' in the title the WHERE clause for the outer query will
-- check that the count of books for the author is equal to the count of books for the number of books with 'Python' in the title (from the inner query)
-- If a new book with the same author ID is added that does not contain the word 'Python' in the title - There single name will be displayed in the view
-- If another author has a book with the 'Python' in the title - no names will be displayed in the view
AS SELECT a.first_name, a.last_name FROM (SELECT books.author_id, authors.first_name, authors.last_name FROM authors, books
WHERE authors.author_id = books.author_id AND
books.title LIKE '%Python%' GROUP BY books.author_id, authors.first_name, authors.last_name) a
WHERE (SELECT COUNT(*) FROM books WHERE author_id = a.author_id AND title LIKE '%Python%') = (SELECT COUNT(*) FROM books WHERE books.title LIKE '%Python%');

--8.Create a view called 'no_cat_customers' that returns the first name, last name of any customer who has not been shipped any edition of the book named 'The Cat in the Hat'.
CREATE VIEW no_cat_customers(customer_first_name, customer_last_name)
-- To find the customers that have not been shipped any edition of 'The Cat in the Hat'
-- Firstly find the first name and last name of customers that have been shipped any edition of 'The Cat in the Hat' in a nested query
-- The outer query will select the first name and last name such that the name is not any of the customers that have been shipped any edition of
-- 'The Cat in the Hat'. This means all of the names returned will be customers who have not been shipped any edition of 'The Cat in the Hat'
AS SELECT first_name, last_name
FROM customers
WHERE (first_name, last_name) NOT IN
(SELECT customers.first_name, customers.last_name FROM books, editions, shipments, customers
WHERE books.book_id = editions.book_id AND
books.title = 'The Cat in the Hat' AND
editions.isbn = shipments.isbn AND
shipments.c_id = customers.c_id);
