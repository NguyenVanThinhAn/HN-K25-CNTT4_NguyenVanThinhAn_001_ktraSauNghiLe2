SET SQL_SAFE_UPDATES = false;
DROP DATABASE test; -- dùng để test nhanh
CREATE DATABASE test;

USE test;

CREATE TABLE Books(
	book_id varchar(5) primary key,
    title varchar(150) not null unique,
    author varchar(100) not null,
    category varchar(50) not null,
    price decimal(10,2) not null,
    status varchar(20) not null check(status IN ("Available","Borrowed","Lost")),
    published_year INT -- dữ liệu có thêm "năm" ở cuối
);

CREATE TABLE Members(
	member_id varchar(5) primary key,
    full_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null,
    membership_type varchar(50) not null check(membership_type IN ("Student","Teacher","Guest"))
);

CREATE TABLE Loans(
	loan_id INT primary key auto_increment,
    book_id varchar(5) not null,
    member_id varchar(5) not null,
    loan_date DATE not null,
    return_date DATE,
    FOREIGN KEY(book_id) REFERENCES Books(book_id),
    FOREIGN KEY(member_id) REFERENCES Members(member_id)
);

CREATE TABLE Fines(
	fine_id INT primary key auto_increment,
    loan_id INT not null,
    fine_amount decimal(10,2) not null,
    fine_reason varchar(255) not null,
    FOREIGN KEY(loan_id) REFERENCES Loans(loan_id)
);

INSERT INTO Books
VALUES
('B01', 'Đất rừng phương Nam', 'Đoàn Giỏi', 'Tiểu thuyết', 120000.00, 'Available', 2020),
('B02', 'Lập trình Python', 'Nguyễn Anh', 'Công nghệ', 250000.00, 'Borrowed', 2022),
('B03', 'Kỹ thuật lập trình C', 'Lê Nam', 'Công nghệ', 180000.00, 'Available', 2021),
('B04', 'Số đỏ', 'Vũ Trọng Phụng', 'Tiểu thuyết', 85000.00, 'Borrowed', 2019),
('B05', 'Tư duy logic', 'Phạm Minh', 'Kỹ năng', 150000.00, 'Available', 2023),
('B06', 'Tư duy Skibidi', 'Phạm Sink', 'Kỹ năng', 350000.00, 'Available', 2021);

INSERT INTO Members
VALUES
('M01', 'Trần Văn An', 'an.tv@gmail.com', '0912345678', 'Student'),
('M02', 'Nguyễn Thị Bình', 'binh.nt@gmail.com', '0987654321', 'Teacher'),
('M03', 'Nguyễn Minh Hiếu', 'hieu.nm@gmail.com', '0911223344', 'Student'),
('M04', 'Phạm Bảo Ngọc', 'ngoc.pb@gmail.com', '0922334455', 'Guest'),
('M05', 'Lê Hồng Anh', 'anh.lh@gmail.com', '0933445566', 'Student'),
('M06', 'Lê Hồng An', 'anh.lt@gmail.com', '0933445562', 'Student');

INSERT INTO Loans
VALUES
(1, 'B02', 'M01', '2025-11-10', '2025-11-20'),
(2, 'B04', 'M03', '2025-11-12', NULL),
(3, 'B01', 'M02', '2025-11-15', '2025-11-25'),
(4, 'B02', 'M05', '2025-12-01', NULL),
(5, 'B03', 'M01', '2025-12-05', '2025-12-15'),
(6, 'B05', 'M03', '2025-12-10', NULL),
(7, 'B01', 'M04', '2025-11-15', NULL),
(8, 'B05', 'M01', '2025-12-05', '2025-12-15'),
(9, 'B01', 'M02', '2025-11-15', '2025-11-25');

INSERT INTO Fines
VALUES
(1, 1, 15000.00, 'Quá hạn 5 ngày'),
(2, 3, 5000.00, 'Làm rách trang sách'),
(3, 5, 20000.00, 'Quá hạn 7 ngày');

-- Yêu cầu cập nhật/xóa:
UPDATE Members SET membership_type = 'Teacher' WHERE member_id = 'M01';
UPDATE Books SET price = price * 1.05 WHERE category = "Công nghệ";
DELETE FROM Fines WHERE fine_amount < 10000;
UPDATE Books SET status = 'Lost' WHERE published_year < 2020;
UPDATE Loans SET return_date = (current_date) WHERE member_id = "B01" AND return_date IS NULL;

-- PHẦN 3: Truy vấn dữ liệu (55 điểm)
-- Liệt kê tất cả sách có giá từ 100,000 đến 500,000.
SELECT *
FROM Books WHERE price > 100000 AND price < 500000;

-- Lấy thông tin full_name, email của độc giả có họ 'Nguyễn'.
SELECT full_name
FROM Members WHERE full_name LIKE "Nguyễn%";

-- Hiển thị danh sách sách gồm title, author, sắp xếp theo price giảm dần.
SELECT title,author
FROM Books
ORDER BY price DESC;

-- Lấy ra 3 cuốn sách mới nhất (dựa trên published_year).
SELECT *
FROM Books
ORDER BY published_year DESC
LIMIT 3;

-- Hiển thị thông tin mượn sách (Loans) diễn ra trong tháng 11/2025.
SELECT *
FROM Loans
WHERE year(loan_date) = 2025 AND month(loan_date) = 11;

-- Hiển thị danh sách các cuốn sách có tên (title) bắt đầu bằng chữ 'L' hoặc kết thúc bằng chữ 'n'
SELECT *
FROM Books WHERE title LIKE "L%" OR title LIKE "%n";

-- Lấy thông tin các đơn mượn sách có ngày mượn (loan_date) nằm trong khoảng từ '2025-11-01' đến '2025-12-15'
SELECT *
FROM Loans
WHERE year(loan_date) = 2025 AND (month(loan_date) >= 11 and month(loan_date) <= 12) and (day(loan_date) >= 1 and day(loan_date) <= 15);

-- Hiển thị danh sách độc giả gồm member_id, full_name, phone và sắp xếp theo tên độc giả (full_name) theo bảng chữ cái (A-Z)
SELECT member_id,full_name,phone
FROM Members
ORDER BY full_name;

-- Nâng cao
-- Hiển thị loan_id, full_name (độc giả), title (sách), loan_date của các độc giả loại 'Student'.
SELECT loa.loan_id,mem.full_name,boo.title,loa.loan_date
FROM Loans loa
JOIN Members mem ON mem.member_id = loa.member_id
JOIN Books boo ON boo.book_id = loa.book_id
WHERE mem.membership_type = "Student";

-- Thống kê mỗi thể loại (category) có bao nhiêu cuốn sách.
SELECT category,COUNT(category)
FROM Books
GROUP BY category;

-- Liệt kê danh sách độc giả và tổng số lần họ đã mượn sách. Hiển thị cả người chưa mượn lần nào.
SELECT mem.full_name, COUNT(loa.member_id)
FROM Loans loa
RIGHT JOIN Members mem ON mem.member_id = loa.member_id
GROUP BY mem.full_name;

-- Tìm các cuốn sách chưa từng được ai mượn.
SELECT *
FROM Books boo
LEFT JOIN Loans loa ON boo.book_id = loa.book_id
WHERE loa.loan_id is NULL;

-- Tính tổng số tiền phạt mà mỗi độc giả phải trả (Hiển thị: full_name, total_fine).
SELECT mem.full_name, SUM(fin.fine_amount) AS "Tiền phạt"
FROM Members mem
JOIN Loans loa ON loa.member_id = mem.member_id
JOIN Fines fin ON fin.loan_id = loa.loan_id
GROUP BY mem.member_id;

-- Hiển thị tên các độc giả đã mượn trên 2 cuốn sách khác nhau.
SELECT mem.full_name
FROM Members mem
JOIN Loans loa ON loa.member_id = mem.member_id
JOIN Books boo ON boo.book_id = loa.book_id
GROUP BY mem.member_id,boo.category
HAVING COUNT(boo.category) < (
	SELECT COUNT(1)
    FROM Books boo2
    JOIN Loans loa2 ON loa2.book_id = boo2.book_id
    JOIN Members mem2 ON mem2.member_id = loa2.member_id
    WHERE boo2.category <> boo.category AND mem2.member_id = mem.member_id
);

-- Tìm độc giả đã mượn cuốn sách có giá cao nhất trong thư viện (Hiển thị: full_name, title, price).
SELECT mem.full_name,boo.title,boo.price
FROM Members mem
JOIN Loans loa ON loa.member_id = mem.member_id
JOIN Books boo ON boo.book_id = loa.book_id
ORDER BY boo.price DESC
LIMIT 1;

SELECT boo.title,boo.author,boo.category
FROM Members mem
JOIN Loans loa ON loa.member_id = mem.member_id
JOIN Books boo ON boo.book_id = loa.book_id
WHERE boo.category = "Tiểu thuyết"
