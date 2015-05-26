{h3, h2, div, form, text, select, option, input, span, table, thead, tr, td, th, tbody} = React.DOM

AddProduct = React.createClass
  handleSubmit: (e) ->
    e.preventDefault()
    cat = (React.findDOMNode @refs.category).value.trim()
    name = (React.findDOMNode @refs.name).value.trim()
    price = (React.findDOMNode @refs.price).value
    stock = (React.findDOMNode @refs.stocked).checked
    if not cat or not name or not price
      return
    @props.addProduct {category: cat, price: price, stocked: stock, name: name}
    (React.findDOMNode @refs.category).value = ''
    (React.findDOMNode @refs.name).value = ''
    (React.findDOMNode @refs.price).value = ''
    (React.findDOMNode @refs.stocked).checked = false
    return
  render: ->
    div {className: 'addProduct'},
      (h3 {}, 'Add a product'),
      form {className: 'commentForm', onSubmit: @handleSubmit},
        select {ref: 'category'},
          option {value: '', disabled: 'disabled', selected:'true'}, 'Category'
          option {value: 'Magic'}, 'Magic'
          option {value: 'Potions'}, 'Potions'
          option {value: 'Frogs'}, 'Frogs'
          option {value: 'Markers'}, 'Markers'
          option {value: 'Wands'}, 'Wands'
          option {value: 'Other'}, 'Other'
        input {type: 'text', placeholder: 'Product', ref: 'name'}
        text {}, '$'
        input {type: 'number', min: '0', step:'0.01', placeholder: 'Price', ref: 'price'}
        input {type: 'checkbox', ref: 'stocked', id: 'instock'}, 'In Stock'
        input {type: 'submit', value: 'Add'}

Row = React.createClass
  render: ->
    instock = @props.product.stocked and @props.product.stocked isnt 'false'
    cat = if instock
            span {style: {color: 'blue'}}, @props.product.category
          else
            span {style: {color: 'red'}}, @props.product.category
    name = if instock
             @props.product.name
           else
             span {style: {color: 'red'}}, @props.product.name
    price = (parseFloat @props.product.price).toFixed 2
    tr {},
     td {}, cat
     td {}, name
     td {}, '$'+price

Table = React.createClass
  render: ->
    rows = []
    rows.push(React.createFactory(Row) {product: product, key: i}) for product,i in @props.products
    table {},
      thead {},
        tr {},
          th {}, 'Category'
          th {}, 'Name'
          th {}, 'Price'
      tbody {}, rows

ProductList = React.createClass
  loadProducts: ->
    $.ajax
      url: @props.url
      dataType: 'json'
      cache: false
      success: ((data) ->
        @setState data: data
        return
      ).bind(this)
      error: ((xhr, status, err) ->
        console.error @props.url, status, err.toString()
        return
      ).bind(this)
  getInitialState: ->
    data: []
  handleAddProduct: (product) ->
    products = @state.data
    products.push product
    @setState {data: products}, ->
      $.ajax
        url: @props.url
        dataType: 'json'
        type: 'POST'
        data: product
        success: ((data) ->
          @setState data:data
          return
        ).bind(this)
        error: ((xhr, status, err) ->
          console.error @props.url, status, err.toString()
          return
        ).bind(this)
      return
  componentDidMount: ->
    @loadProducts()
    setInterval @loadProducts, @props.pollInterval
  render: ->
    div {className: 'ProductList'},
      (h2 {}, 'Products'),
      React.createFactory(AddProduct) {addProduct: @handleAddProduct}
      React.createFactory(Table) {products: @state.data}

React.render (React.createFactory(ProductList) {url: './products.json', pollInterval: 1000}),
  document.getElementById('content')
