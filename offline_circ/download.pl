#!/usr/bin/perl

# Copyright 2013 C & P Bibliography Services
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use Modern::Perl;
use CGI;
use JSON;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Koha;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie, $flags ) =
  checkauth( $query, undef, { circulate => "circulate_remaining_permissions" },
    "intranet" );

my $page     = $query->param('page') || 0;
my $startrec = int($page) * 5000;
my $req_data = $query->param('data') || '';

my $patrons_query = qq{SELECT
    borrowers.borrowernumber, cardnumber, surname, firstname, title,
    othernames, initials, streetnumber, streettype, address, address2, city,
    state, zipcode, country, email, phone, mobile, fax, dateofbirth, branchcode,
    categorycode, dateenrolled, dateexpiry, gonenoaddress, lost, debarred,
    debarredcomment, SUM(accountlines.amountoutstanding) AS fine
    FROM borrowers
    LEFT JOIN accountlines ON borrowers.borrowernumber=accountlines.borrowernumber
    GROUP BY borrowers.borrowernumber
    LIMIT $startrec, 5000;
    };

# NOTE: we can't fit very long titles on the interface so there isn't really any point in transferring them
my $items_query = qq{SELECT
    items.barcode AS barcode, items.itemnumber AS itemnumber,
    items.itemcallnumber AS callnumber, items.homebranch AS homebranch,
    items.holdingbranch AS holdingbranch, items.itype AS itemtype,
    items.materials AS materials, LEFT(biblio.title, 60) AS title,
    biblio.author AS author, biblio.biblionumber AS biblionumber
    FROM items
    JOIN biblio ON biblio.biblionumber = items.biblionumber
    LIMIT $startrec, 5000;
    };

my $issues_query = qq{SELECT
    biblio.title AS title,
    items.barcode AS barcode,
    items.itemcallnumber AS callnumber,
    issues.date_due AS date_due,
    issues.issuedate AS issuedate,
    issues.renewals AS renewals,
    borrowers.cardnumber AS cardnumber,
    CONCAT(borrowers.surname, ', ', borrowers.firstname) AS borrower_name
    FROM issues
    JOIN items ON items.itemnumber = issues.itemnumber
    JOIN biblio ON biblio.biblionumber = items.biblionumber
    JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber
    LIMIT $startrec, 5000;
    };

if ( $req_data eq 'all' ) {
    print $query->header( -type => 'application/json', -charset => 'utf-8' );
    print to_json(
        {
            'patrons' => get_data( $patrons_query, 'cardnumber' ),
            'items'   => get_data( $items_query,   'barcode' ),
            'issues'  => get_data( $issues_query,  'barcode' ),
        }
    );
}
elsif ( $req_data eq 'patrons' ) {
    print $query->header( -type => 'application/json', -charset => 'utf-8' );
    print to_json( { 'patrons' => get_data( $patrons_query, 'cardnumber' ), } );
}
elsif ( $req_data eq 'items' ) {
    print $query->header( -type => 'application/json', -charset => 'utf-8' );
    print to_json( { 'items' => get_data( $items_query, 'barcode' ), } );
}
elsif ( $req_data eq 'issues' ) {
    print $query->header( -type => 'application/json', -charset => 'utf-8' );
    print to_json( { 'issues' => get_data( $issues_query, 'barcode' ), } );
}

sub get_data {
    my ( $sql, $key ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    return $sth->fetchall_hashref($key);
}