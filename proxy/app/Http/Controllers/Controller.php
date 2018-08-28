<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

use Illuminate\Support\Facades\Log;

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

      $dir = '/html/'.$request->get('workspace').'/'.$request->get('inventory-name');
      $imageName = $request->get('file-name') . '.' . $request->get('file-extension');
      $thumbnailName = $request->get('file-name') . 't.' . $request->get('file-extension');
      $tmpDir = tempnam(sys_get_temp_dir(), 'maxanet_');

      try {
        $image = new \Imagick($request->file->getRealPath());
      } catch (\ImagickException $e) {
        return [$e->getCode() => $e->getMessage(), 'path' => $request->file->getRealPath()];
      }

      $image->thumbnailImage(640, 480, true);

      if ($image->getImageHeight() > $image->getImageWidth()) {
        $image->imageRotate(90);
      }

      $image->writeImage($tmpDir.$imageName);

      try {
        $thumbnail = new \Imagick($request->file->getRealPath());
      } catch (\ImagickException $e) {
        return [$e->getCode() => $e->getMessage(), 'path' => $request->file->getRealPath()];
      }
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

      // required or we get 504 timeouts
      ftp_pasv($connection, true);

      $dirs = ftp_nlist($connection, '/html');

      if (!in_array('/html/'.$request->get('workspace'), $dirs)) {
        ftp_mkdir($connection, '/html/'.$request->get('workspace'));
      }

      $name_dirs = ftp_nlist($connection, '/html/'.$request->get('workspace'));
      Log::debug('Making a Directory: ' . $dir);
      if (!in_array($dir, $name_dirs)) {
        ftp_mkdir($connection, $dir);
      }

      ftp_put(
        $connection,
        $dir.'/'.$imageName,
        $tmpDir.$imageName,
        FTP_BINARY
      );

      ftp_put(
        $connection,
        $dir.'/'.$thumbnailName,
        $tmpDir.$thumbnailName,
        FTP_BINARY
      );

      return [
        'imageName' => $request->get('inventory-name').'/'.$imageName, 
        'thumbnailName' => $request->get('inventory-name').'/'.$thumbnailName,
      ];

    }

  }
}


// /usr/local/lib/php/pecl/20160303/imagick.so
