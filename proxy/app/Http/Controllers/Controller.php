<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

// use Illuminate\Support\Facades\Log;

class Controller extends BaseController
{
  use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

  function verify (Request $request)
  {

    $connection = @ftp_connect($request->get('ftp-host'));
    if (!$connection) {
      return ['valid' => false];
    }

    if (@ftp_login(
      $connection,
      $request->get('ftp-user'),
      $request->get('ftp-password'))) {
      return ['valid' => true];
    }

    return ['valid' => false];
  }

  function index(Request $request) {
     Artisan::call('route:list');
    return '<pre>'.Artisan::Output().'</pre>';

  }

  function upload (Request $request) {

    if (isset($request->file)) {

      $dir = '/html/'.$request->get('workspace').'/';
      $imageName = $request->get('file-name') . '.' . $request->get('file-extension');
      $thumbnailName = $request->get('file-name') . 't.' . $request->get('file-extension');

      $tmpDir = tempnam(sys_get_temp_dir(), 'maxanet_');

      $image = new \Imagick($request->file->getPathname());
      $image->thumbnailImage(640, 480, true);
      $image->writeImage($tmpDir.$imageName);

      $thumbnail = new \Imagick($request->file->getPathname());
      $thumbnail->thumbnailImage(240, 240, true);
      $thumbnail->writeImage($tmpDir.$thumbnailName);

      /*
      header('Content-Type: image/jpeg');
      $test = new \Imagick($tmpDir.$imageName);
      echo $test->getImageBlob();
      */

      $connection = ftp_connect($request->get('ftp-host'));

      ftp_login(
        $connection,
        $request->get('ftp-user'),
        $request->get('ftp-password'));

      $dirs = ftp_nlist($connection, '/html');

      if (!in_array('/html/'.$request->get('workspace'), $dirs)) {
        ftp_mkdir($connection, $dir);
      }

      ftp_put(
        $connection,
        $dir.$imageName,
        $tmpDir.$imageName,
        FTP_BINARY
      );

      ftp_put(
        $connection,
        $dir.$thumbnailName,
        $tmpDir.$thumbnailName,
        FTP_BINARY
      );

      return ftp_nlist($connection, '/');

    }

  }
}


// /usr/local/lib/php/pecl/20160303/imagick.so