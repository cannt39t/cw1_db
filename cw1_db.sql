

-- 1


CREATE TABLE filial(
    id serial primary key,
    city text
);

CREATE TABLE client(
    id serial primary key,
    fio text,
    passport integer not null,
    count_of_loans integer default 0,
    max_sum_of_loans integer default 50000,
        check(client.max_sum_of_loans <= 50000 + client.count_of_loans * 20000
            and client.max_sum_of_loans <= 150000),
    filial_id serial references filial(id)
);

CREATE TABLE loan(
    id serial primary key,
    client_id serial references client(id),
    client_max_sum_of_loans integer,
    sum integer not null
        check ( sum <= client_max_sum_of_loans),
    date_of_loan date DEFAULT CURRENT_TIMESTAMP,
    close_or_not boolean default false
);

CREATE TABLE payment(
    id serial primary key,
    client_id serial references client(id),
    loan_id serial references loan(id),
    loan_date date,
    loan_sum integer,
    payment_date timestamp
        check ( (DATE_PART('day', payment.payment_date - loan_date)) <= 61),
    payment integer
        check ( payment = loan_sum * (1 + (DATE_PART('day', payment.payment_date - loan_date)) / 100 ))
);


-- 2


INSERT INTO filial(city)
    values('Kazan'),
          ('Moscow');

INSERT INTO client(fio, passport, count_of_loans, max_sum_of_loans, filial_id)
VALUES ('Селянцев Владислав Андреевичб', 2343544, 0, 50000, 1),
       ('Казначеев Илья Андреевичб', 3435544, 1, 70000, 1),
       ('Маратов Солнце Андреевичб', 2324544, 2, 90000, 2),
       ('Шарипова Руслана Андреевичб', 4243544, 1, 70000, 2),
       ('Шарипова Руслана Андреевичб', 4243544, 5, 150000, 1);

INSERT INTO loan(client_id, client_max_sum_of_loans, sum, date_of_loan, close_or_not)
VALUES (1, 50000, 30000, '2022.10.10', false),
       (2, 70000, 70000, '2022.5.10', false),
       (3, 90000, 10000, '2022.11.10', true),
       (4, 70000, 70000, '2022.11.30', false),
       (5, 150000, 15000, '2022.09.30', true),
       (5, 150000, 30000, '2022.08.30', true),
       (5, 150000, 20000, '2022.07.30', true),
       (5, 150000, 10000, '2022.06.30', true);

INSERT INTO payment(client_id, loan_id, loan_date, loan_sum, payment_date, payment)
VALUES  (3 ,3, '2022.11.10', 10000, '2022.11.20', 11000),
        (5 ,5, '2022.09.01', 15000, '2022.09.11', 16500),
        (5 ,6, '2022.08.01', 30000, '2022.08.11', 33000),
        (5 ,7, '2022.07.01', 20000, '2022.07.11', 22000),
        (5 ,8, '2022.06.01', 10000, '2022.06.11', 11000);


-- 3


select * from loan
where close_or_not = false;


-- 4


select filial.id, sum(sum) as sum_of_loan
from filial
join client c on filial.id = c.filial_id
join loan l on c.id = l.client_id
group by filial.id
order by sum_of_loan desc limit 1;


-- 5


select fio, passport, sum(loan.sum * (1 + (DATE_PART('day', CURRENT_TIMESTAMP - loan.date_of_loan::date)) / 100)) as sum_of_loans
from loan
join client c on loan.client_id = c.id
    and ( (DATE_PART('day', CURRENT_TIMESTAMP - loan.date_of_loan::date)) > 61)
group by fio, passport;