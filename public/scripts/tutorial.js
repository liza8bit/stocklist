var AddProduct = React.createClass({
  handleSubmit:function(e) {
    e.preventDefault();
    var cat=React.findDOMNode(this.refs.category).value.trim();
    var name=React.findDOMNode(this.refs.name).value.trim();
    var price = React.findDOMNode(this.refs.price).value.trim();
    var stock = React.findDOMNode(this.refs.stocked).value();
    if(!cat || !product || !price){
      return;
    }
    this.props.onSubmit({category: cat, price: price, stocked: stock, name: name});
    React.findDOMNode(this.refs.category).value='';
    React.findDOMNode(this.refs.name).value='';
    React.findDOMNode(this.refs.price).value='';
  },
  render: function() {
    return (
        <div className="addProduct">
        <h3> Add a product </h3>
        <form className="commentForm">
        <input type="text" placeholder= "Category" ref="category"/>
        <input type="text" placeholder= "Product" ref="name"/>
        <input type="text" placeholder= "Price" ref="price"/>
        <input type="checkbox" name="stock" ref="stocked">In Stock </input>
        <input type="submit" value="Add" />
        </form>
        </div>
        );
  }
});

var Row = React.createClass({
  render: function(){
    var cat= this.props.product.stocked ?
      <span style={{color: 'blue'}}>
      {this.props.product.category} </span> :
      <span style={{color: 'red'}}>
      {this.props.product.category} </span>
    var name=this.props.product.stocked ?
      this.props.product.name : 
      <span style={{color: 'red'}}>
        {this.props.product.name}
        </span>;
    return(
      <tr>
        <td>{cat}</td>
        <td>{name}</td>
        <td>{this.props.product.price}</td>
      </tr>
    );
  }
});

var Table = React.createClass({
  render: function() {
    var rows = [];
    var last=null;
    var newrows = this.props.products.map(function (product) {
        return(<Row product={product} key={product.name} />);
    });
    return(
      <table>
        <thead>
          <tr>
            <th>Category</th>
            <th>Name</th>
            <th>Price</th>
          </tr>
        </thead>
        <tbody>{newrows}</tbody>
      </table>
    );
          }
});

var ProductList = React.createClass({
  loadProducts: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr,status,err){
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  handleAddProduct: function(product) {
    var products = this.state.data;
    products.push(product);
    this.setState({data: comments}, function(){
      $.ajax({
        url:this.props.url,
        dataType: 'json',
        type: 'POST',
        data: product,
        success: function(data) {
          this.setState({data: data});
        }.bind(this),
        error: function(xhr, status, err){
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    });
  },
  componentDidMount: function(){
    this.loadProducts();
    setInterval(this.loadProducts, this.props.pollInterval);
  },
  render: function() {
    return(
        <div className="ProductList">
        <h2>Products</h2>
        <AddProduct onSubmit={this.handleAddProduct} />
        <Table products={this.state.data}/>
        </div>
        );
  }
});
  
React.render(<ProductList url="./products.json" pollInterval={1000}/>, 
  document.getElementById('content'));
