(* Mathematica source file *)
(* :Author: Diego Zviovich *)
(* :Date: 12/21/15 *)
(* :Comments: Code based on Patrick Scheibe's installer.m *)

With[
  {
    repositoryURL = "https://github.com/catrasca/RadarChart/archive/master.zip",
    repositoryDir = "RadarChart-master", (* This is fixed by GitHub which always names the ZIP content like this *)
    zipFileName = FileNameJoin[{$TemporaryDirectory, "master.zip" }]

  },
  Module[
    {
      extractedDir = FileNameJoin[{$TemporaryDirectory, repositoryDir }],
      existingFiles,
      zipFile,
      deleteQDialog,
      fetchURL
    },

    If[$VersionNumber < 9,
      Get["Utilities`URLTools`"];
      fetchURL = FetchURL,
      fetchURL = URLSave
    ];

    deleteQDialog[str_String] := With[{dirQ = DirectoryQ[str]}, ChoiceDialog[
      "The following " <> If[dirQ, "directory", "file"] <> " already exists:\n" <> str <> "\nDelete it?",
      {
        "Yes" :> Quiet@Check[
          If[dirQ, DeleteDirectory[str, DeleteContents -> True], DeleteFile[str]],
          MessageDialog["Error. Could not delete. Aborting"]; $Aborted],
        "No" :> $Aborted
      }]
    ];

    existingFiles = Select[Flatten[{zipFileName, extractedDir, FileNames[#, $Path]& /@ {"RadarChart", "RadarChart"}}], FileExistsQ];
    Do[
      If[deleteQDialog[f] === $Aborted,
        Print["Could not delete " <> f];
        Abort[]
      ], {f, existingFiles}
    ];

    zipFile = fetchURL[repositoryURL, zipFileName];
    If[Not[FileExistsQ[zipFile]],
      Print[ "Couldn't download resource" ];
      Abort[];
    ];
    ExtractArchive[zipFile, $TemporaryDirectory];
    CopyDirectory[FileNameJoin[{$TemporaryDirectory, repositoryDir , "RadarChart" }],
      FileNameJoin[{$UserAddOnsDirectory, "Applications" , "RadarChart" }]];
    DeleteDirectory[FileNameJoin[{$TemporaryDirectory, repositoryDir }], DeleteContents -> True];
    DeleteFile[zipFile];
    FrontEndExecute[FrontEnd`ResetMenusPacket[{Automatic, Automatic}]];

  ]
]
