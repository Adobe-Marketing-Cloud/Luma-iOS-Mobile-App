<?php 

    // POST Variables
    $name = $_POST['name'];
    $fromEmail = $_POST['fromEmail'];
    $receiverEmail = $_POST['receiverEmail'];
    $messageBody = $_POST['messageBody'];
    $storeName = $_POST['storeName'];
    $shippingAddress = $_POST['shippingAddress'];
    $headers = 'From: ' .$fromEmail;

    // SUBJECT 
    $subject = "New order from " .$name. " on '" .$storeName. "'";


    // COMPOSE MESSAGE 
    $message = 
    "ORDER DETAILS:\n".
    $messageBody.
    "\n\nName: " .$name. 
    "\nUser Email: " .$fromEmail.
    "\nShipping Address: " .$shippingAddress
    ;

    /* Finally send email */
    mail($receiverEmail,
        $subject, 
        $message, 
        $headers
    );

    /* Result */
    echo "Email Sent to: " .$receiverEmail. "\n Message: " .$message;
?>
