// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Library is Ownable {
    event NewBookAdded(uint id, string name);
    event BookBorrowed(uint id, address user);
    event BookReturned(uint id, address user);

    struct Book {
        string name;
        uint id;
        uint16 numberOfCopies;
        uint16 availableCopies;
    }

    Book[] private books;
    mapping(uint => address[]) private booksBorrowHistory;
    mapping(string => bool) private bookNameToId;
    mapping(address => mapping(uint => bool)) private borrowedBooks;

    function addBook(string memory _name, uint16 _numberOfCopies) public onlyOwner returns (uint Id){
        require(bookNameToId[_name] != true, "This book is already added.");
		
        uint id = books.length;
        bookNameToId[_name] = true;
        books.push(Book(_name, id, _numberOfCopies, _numberOfCopies));

        emit NewBookAdded(books[id].id, books[id].name);
        return id;
    }

    function updateNumberOfCopies(uint _bookId, uint16 _numberOfCopies) public onlyOwner {
        require(_numberOfCopies >= books[_bookId].numberOfCopies - books[_bookId].availableCopies, "You can't reduce the book copies to a number less than the borrowed ones.");
		
        books[_bookId].availableCopies = books[_bookId].availableCopies - books[_bookId].numberOfCopies + _numberOfCopies;
        books[_bookId].numberOfCopies = _numberOfCopies;
    }

    function borrowBook(uint _bookId) public {
        require(books[_bookId].availableCopies > 0, "Sorry we don't have an available copy of this book at the moment.");
        require(borrowedBooks[msg.sender][_bookId] != true, "Sorry you can't borrow a second coppy of this book.");
        
        books[_bookId].availableCopies--;
        borrowedBooks[msg.sender][_bookId] = true;
        booksBorrowHistory[_bookId].push(msg.sender); //Im not sure if we have to hold every borrowing, but we do

        emit BookBorrowed(_bookId, msg.sender);
    }

    function returnBook(uint _bookId) public {
        require(borrowedBooks[msg.sender][_bookId] == true, "This book is not borrowed from our library.");
        
        books[_bookId].availableCopies++;
        borrowedBooks[msg.sender][_bookId] = false;

        emit BookReturned(_bookId, msg.sender);
    }

    function getBooks() public view returns(Book[] memory) {
        return books;
    }

    function getBookBorrowHistory(uint _bookId) public view returns(address[] memory) {
        return booksBorrowHistory[_bookId];
    }
}