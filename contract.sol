// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ECommerce {
    address public owner;
    uint256 public productCount;

    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    mapping (uint256 => Product) public products;
    mapping (address => uint256) public balance;

    event ProductCreated(uint256 id, string name, uint256 price, address seller);
    event ProductPurchased(uint256 id, string name, uint256 price, address seller, address buyer);

    function createProduct(string memory _name, string memory _description, uint256 _price) public {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(bytes(_description).length > 0, "Product description cannot be empty");
        require(_price > 0, "Price must be greater than 0");

        productCount++;

        products[productCount].id = productCount;
        products[productCount].name = _name;
        products[productCount].description = _description;
        products[productCount].price = _price;
        products[productCount].seller = payable(msg.sender);
        products[productCount].isSold = false;

        /* products[productCount] = Product({
            id: productCount,
            name: _name,
            description: _description,
            price: _price,
            seller: payable(msg.sender),
            isSold: false
        }); */

        emit ProductCreated(productCount, _name, _price, msg.sender);
    }

    function purchaseProduct(uint256 _productId) public payable {
        Product memory product = products[_productId];
        require(product.id > 0 && !product.isSold, "Product does not exist or is already sold");
        require(msg.value >= product.price, "Insufficient funds sent");

        product.isSold = true;
        product.seller.transfer(product.price);

        balance[msg.sender] -= msg.value;
        balance[product.seller] += product.price;

        emit ProductPurchased(product.id, product.name, product.price, product.seller, msg.sender);
    }
}
