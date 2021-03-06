INSERT INTO userflags (bit, flag, flagdesc, defaulton) VALUES
(0,'superlibrarian','Access to all librarian functions',0),
(1,'circulate','Check out and check in items',0),
(2,'catalogue','<b>Required for staff login.</b> Staff access, allows viewing of catalogue in staff client.',0),
(3,'parameters','Manage Koha system settings (Administration panel)',0),
(4,'borrowers','Add or modify patrons',0),
(5,'permissions','Set user permissions',0),
(6,'reserveforothers','Place and modify holds for patrons',0),
(7,'borrow','Borrow books',1),
(9,'editcatalogue','Edit Catalog (Modify bibliographic/holdings data)',0),
(10,'updatecharges','Manage patrons fines and fees',0),
(11,'acquisition','Acquisition and/or suggestion management',0),
(12,'management','Set library management parameters (deprecated)',0),
(13,'tools','Use all tools (expand for granular tools permissions)',0),
(14,'editauthorities','Edit Authorities',0),
(15,'serials','Manage serial subscriptions',0),
(16,'reports','Allow access to the reports module',0),
(17,'staffaccess','Allow staff members to modify permissions for other staff members',0),
(18,'coursereserves','Course Reserves',0),
(19, 'plugins', 'Koha plugins', '0');
