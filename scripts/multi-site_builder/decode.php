<?php

$string = file_get_contents("$argv[1]");
$json = json_decode($string, TRUE);

if (strcmp($argv[2], "sites_count") == 0) {
  $result = count($json['sites']);
  print_r($result);
}
else {
  if (strcmp($argv[2], "machine_name") == 0) {
    $keys = array_keys($json['sites']);
    print_r($keys[$argv[3]]);
  }
  else {
    foreach ($json as $values) {
      $values = array_values($json['sites']);
      if (is_array($values[$argv[2]][$argv[3]])) {
        print_r(implode(',', $values[$argv[2]][$argv[3]]));
      }
      else {
        print_r($values[$argv[2]][$argv[3]]);
      }
    }
  }
}
