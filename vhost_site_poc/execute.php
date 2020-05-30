<html>
<body>
<?php $name = escapeshellarg($_POST["name"]); ?>
<?php $password = escapeshellarg($_POST["password"]); ?>
<?php $domain = escapeshellarg($_POST["domain"]); ?>

<?php $page = shell_exec("sudo /var/www/html/vhost.sh $name $password $domain"); ?>
<p>Webinstance for the following user succesfully created! </p>

Name: <?php echo $name; ?><br>
Password: <?php echo $password; ?><br>
Domain: <?php echo $domain; ?><br>


</body>
</html> 