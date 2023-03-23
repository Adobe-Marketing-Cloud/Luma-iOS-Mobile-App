<?php 

    // POST Variables
    $name = $_POST['name'];
    $fromEmail = $_POST['storeName'];
    $receiverEmail = $_POST['receiverEmail'];
    $messageBody = $_POST['messageBody'];
    $storeName = $_POST['Luma'];
    $shippingAddress = $_POST['shippingAddress'];
    $headers = 'From: Luma' .$storeName;

    // SUBJECT 
    $subject = "Your order on " .$storeName. "";


    // COMPOSE MESSAGE 
    $message = 
    "Your Order on " .$storeName.
    ":\n" .$messageBody.
    "\nYour shipping address: " .$shippingAddress.
    "\n\nThanks for buying on ".$storeName.
    "!\nYou can track your Order from the 'Orders' page in the app.\n\nFor any questions/feedback, you may get in touch with us at " .$fromEmail.
    "\n\nBest Regards."
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
