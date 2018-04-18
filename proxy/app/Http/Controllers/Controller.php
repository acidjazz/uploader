<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\Request;
// use Illuminate\Support\Facades\Log;

class Controller extends BaseController
{
  use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

  function index (Request $request) {

    if (isset($request->file)) {

      $dir = '/html/'.$request->get('workspace').'/';
      $imageName = $request->get('file-name') . '.' . $request->get('file-extension');
      $thumbnailName = $request->get('file-name') . 't.' . $request->get('file-extension');

      $tmpdir = tempnam(sys_get_temp_dir(), 'maxanet_');

      $image = new \Imagick($request->file->getPathname());
      $image->thumbnailImage(640, 480, true);
      $image->writeImage($tmpdir.$imageName);

      $thumbnail = new \Imagick($request->file->getPathname());
      $thumbnail->thumbnailImage(240, 240, true);
      $thumbnail->writeImage($tmpdir.$thumbnailName);

      /*
      header('Content-Type: image/jpeg');
      $test = new \Imagick($tmpdir.$imageName);
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
        $tmpdir.$imageName,
        FTP_BINARY
      );

      ftp_put(
        $connection,
        $dir.$thumbnailName,
        $tmpdir.$thumbnailName,
        FTP_BINARY
      );

      return ftp_nlist($connection, '/');

    }

  }
}


// /usr/local/lib/php/pecl/20160303/imagick.so