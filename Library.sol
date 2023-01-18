// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Ownable.sol";

// The administrator (owner) of the library should be able to add new books and the number of copies in the library.
// Users should be able to see the available books and borrow them by their id.
// Users should be able to return books.
// A user should not borrow more than one copy of a book at a time. The users should not be able to borrow a book more times than the copies in the libraries unless copy is returned.
// Everyone should be able to see the addresses of all people that have ever borrowed a given book.

contract Library is Ownable {
    event BookCreated(uint id, string name, uint copies);

    struct Book {
        uint id;
        string name;
        uint copies;
    }

    mapping(uint => mapping(address => bool)) hasEverBorrowed;
    mapping(uint => address[]) borrowersByBook;
    mapping(address => mapping(uint => bool)) currentlyBorrowed;

    Book[] public books;

    function addBook(string memory name, uint copies) external onlyOwner {
        uint id = books.length;
        books.push(Book(id, name, copies));
        emit BookCreated(id, name, copies);
    }

    function borrow(uint bookId) external {
        Book storage book = books[bookId];
        require(book.copies > 0, "No available copies!");
        require(!currentlyBorrowed[msg.sender][bookId], "This book is already borrowed by you!");
        if(!hasEverBorrowed[bookId][msg.sender]) {
            hasEverBorrowed[bookId][msg.sender] = true;
            borrowersByBook[bookId].push(msg.sender);
        }
        currentlyBorrowed[msg.sender][bookId] = true;
        book.copies--;
    }

    function returnBook(uint bookId) external {
        require(currentlyBorrowed[msg.sender][bookId], "The book has not been borowed!");
        Book storage book = books[bookId];
        currentlyBorrowed[msg.sender][bookId] = false;
        book.copies++;
    }

    function getBorrowers(uint bookId) external view returns(address[] memory) {
        return borrowersByBook[bookId];
    }
}
