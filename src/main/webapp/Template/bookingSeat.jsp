<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link type="image/png" rel="icon" size="512x512" href="../Assets/flighticon.png"> 
<title>DeliceJet</title>
<link href="http://www.jqueryscript.net/css/jquerysctipttop.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="jquery.seat-charts.css">
<style>
body {
	font-family: 'Roboto', sans-serif;
  background-color:#fafafa;
}
a {
	color: #b71a4c;
}
.front-indicator {
	width: 145px;
	margin: 5px 32px 15px 32px;
	background-color: #f6f6f6;	
	color: #adadad;
	text-align: center;
	padding: 3px;
	border-radius: 5px;
}
.wrapper {
	width: 100%;
	text-align: center;
  margin-top:150px;
}
.container {
	margin: 0 auto;
	width: 500px;
	text-align: left;
}
.booking-details {
	float: left;
	text-align: left;
	margin-left: 35px;
	font-size: 12px;
	position: relative;
	height: 401px;
}
.booking-details h2 {
	margin: 25px 0 20px 0;
	font-size: 17px;
}
.booking-details h3 {
	margin: 5px 5px 0 0;
	font-size: 14px;
}
div.seatCharts-cell {
	color: #182C4E;
	height: 25px;
	width: 25px;
	line-height: 25px;
	
}
div.seatCharts-seat {
	color: #FFFFFF;
	cursor: pointer;	
}
div.seatCharts-row {
	height: 35px;
}
div.seatCharts-seat.available {
	background-color: #B9DEA0;

}
div.seatCharts-seat.available.first-class {
/* 	background: url(vip.png); */
	background-color: #3a78c3;
}
div.seatCharts-seat.focused {
	background-color: #76B474;
}
div.seatCharts-seat.selected {
	background-color: #E6CAC4;
}
div.seatCharts-seat.unavailable {
	background-color: #472B34;
}
div.seatCharts-container {
	border-right: 1px dotted #adadad;
	width: 200px;
	padding: 20px;
	float: left;
}
div.seatCharts-legend {
	padding-left: 0px;
	position: absolute;
	bottom: 16px;
}
ul.seatCharts-legendList {
	padding-left: 0px;
}
span.seatCharts-legendDescription {
	margin-left: 5px;
	line-height: 30px;
}
.checkout-button {
	display: block;
	margin: 10px 0;
	font-size: 14px;
}
#selected-seats {
	max-height: 90px;
	overflow-y: scroll;
	overflow-x: none;
	width: 170px;
}
</style>
</head>

<body>
<div class="wrapper">
  <div class="container">
  <h1>Please Select Seat...</h1>
    <div id="seat-map">
      <div class="front-indicator">Uçak Önü</div>
    </div>
    <div class="booking-details">
      <h2>Rezervasyon Detayları</h2>
      <h3> Seçilen Koltuklar(<span id="counter">0</span>):</h3>
      <ul id="selected-seats">
      </ul>
      Ücret <b>₺<span id="total">0</span></b>
      <a class="checkout-button" href="flightPayment.jsp">Continue...</a>
      <div id="legend"></div>
    </div>
  </div>
</div>
<script src="http://code.jquery.com/jquery-1.12.4.min.js"></script> 
<script src="jquery.seat-charts.js"></script> 
<script>
var firstSeatLabel = 1;

$(document).ready(function() {
        var $cart = $('#selected-seats'),
                $counter = $('#counter'),
                $total = $('#total'),
                sc = $('#seat-map').seatCharts({
                map: [
                        'ff_ff',
                        'ff_ff',
                        'ee_ee',
                        'ee_ee',
                        'ee___',
                        'ee_ee',
                        'ee_ee',
                        'ee_ee',
                        'eeeee',
                ],
                seats: {
                        f: {
                                price   : 89,
                                classes : 'first-class', //your custom CSS class
                                category: 'First Class'
                        },
                        e: {
                                price   : 29,
                                classes : 'economy-class', //your custom CSS class
                                category: 'Economy Class'
                        }					

                },
                naming : {
                        top : false,
                        getLabel : function (character, row, column) {
                                return firstSeatLabel++;
                        },
                },
                legend : {
                        node : $('#legend'),
                    items : [
                                [ 'f', 'available',   'First Class' ],
                                [ 'e', 'available',   'Economy Class'],
                                [ 'f', 'unavailable', 'Önceden Rezerve Edilmiş']
                    ]					
                },
                click: function () {
                        if (this.status() == 'available') {
                                //let's create a new <li> which we'll add to the cart items
                                $('<li>'+this.data().category+' Koltuk # '+this.settings.label+': <b>₺'+this.data().price+'</b> <a href="#" class="cancel-cart-item">[iptal]</a></li>')
                                        .attr('id', 'cart-item-'+this.settings.id)
                                        .data('seatId', this.settings.id)
                                        .appendTo($cart);

                                /*
                                 * Lets update the counter and total
                                 *
                                 * .find function will not find the current seat, because it will change its stauts only after return
                                 * 'selected'. This is why we have to add 1 to the length and the current seat price to the total.
                                 */
                                $counter.text(sc.find('selected').length+1);
                                $total.text(recalculateTotal(sc)+this.data().price);

                                return 'selected';
                        } else if (this.status() == 'selected') {
                                //update the counter
                                $counter.text(sc.find('selected').length-1);
                                //and total
                                $total.text(recalculateTotal(sc)-this.data().price);

                                //remove the item from our cart
                                $('#cart-item-'+this.settings.id).remove();

                                //seat has been vacated
                                return 'available';
                        } else if (this.status() == 'unavailable') {
                                //seat has been already booked
                                return 'unavailable';
                        } else {
                                return this.style();
                        }
                }
        });

        //this will handle "[cancel]" link clicks
        $('#selected-seats').on('click', '.cancel-cart-item', function () {
                //let's just trigger Click event on the appropriate seat, so we don't have to repeat the logic here
                sc.get($(this).parents('li:first').data('seatId')).click();
        });

        //let's pretend some seats have already been booked
        sc.get(['1_2', '4_1', '7_1', '7_2']).status('unavailable');

});

function recalculateTotal(sc) {
var total = 0;

//basically find every selected seat and sum its price
sc.find('selected').each(function () {
        total += this.data().price;
});

return total;
}

</script><script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-36251023-1']);
  _gaq.push(['_setDomainName', 'jqueryscript.net']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</body>
</html>