// Author: Hugo Pointcheval
// Email: git@pcl.ovh
// -----
// File: benchmark_page.dart
// Created Date: 28/12/2021 15:12:39
// Last Modified: 25/05/2022 15:26:42
// -----
// Copyright (c) 2021

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_crypto/native_crypto.dart';
import 'package:native_crypto_example/pointycastle/aes_gcm.dart';
import 'package:native_crypto_example/widgets/button.dart';

import '../session.dart';
import '../widgets/output.dart';

class BenchmarkPage extends ConsumerWidget {
  BenchmarkPage({Key? key}) : super(key: key);

  final Output keyContent = Output();
  final Output benchmarkStatus = Output(large: true);

  Future<void> _benchmarkEncryptionOnly(
    WidgetRef ref,
    Cipher cipher,
  ) async {
    Session state = ref.read(sessionProvider.state).state;
    AesGcm pc = AesGcm();

    if (state.secretKey.bytes.isEmpty) {
      benchmarkStatus
          .print('No SecretKey!\nGo in Key tab and generate or derive one.');
      return;
    }

    benchmarkStatus.print("Benchmark 2/4/8/16/32/64/128/256MB\n");
    List<int> testedSizes = [2, 4, 8, 16, 32, 64, 128, 256];
    String csv = "size;encryption time\n";

    var beforeBench = DateTime.now();
    Cipher.bytesCountPerChunk = Cipher.bytesCountPerChunk;
    benchmarkStatus
        .append('[Benchmark] ${Cipher.bytesCountPerChunk} bytes/chunk \n');
    for (int size in testedSizes) {
      var b = Uint8List(size * 1000000);
      csv += "${size * 1000000};";

      // Encryption
      var before = DateTime.now();
      var encryptedBigFile = await cipher.encrypt(b, null);
      var after = DateTime.now();

      var benchmark =
          after.millisecondsSinceEpoch - before.millisecondsSinceEpoch;
      benchmarkStatus.append('[$size MB] Encryption took $benchmark ms\n');

      csv += "$benchmark\n";
    }
    var afterBench = DateTime.now();
    var benchmark =
        afterBench.millisecondsSinceEpoch - beforeBench.millisecondsSinceEpoch;
    var sum = testedSizes.reduce((a, b) => a + b);
    benchmarkStatus.append(
        'Benchmark finished.\nGenerated, and encrypted $sum MB in $benchmark ms');
    debugPrint("[Benchmark cvs]\n$csv");
  }

  Future<void> _benchmark(WidgetRef ref, Cipher cipher,
      {bool usePc = false}) async {
    Session state = ref.read(sessionProvider.state).state;
    AesGcm pc = AesGcm();

    if (state.secretKey.bytes.isEmpty) {
      benchmarkStatus
          .print('No SecretKey!\nGo in Key tab and generate or derive one.');
      return;
    }

    benchmarkStatus.print("Benchmark 2/4/8/16/32/64/128/256MB\n");
    List<int> testedSizes = [2, 4, 8, 16, 32, 64, 128, 256];
    String csv = "size;encryption time;decryption time;crypto time\n";

    var beforeBench = DateTime.now();
    Cipher.bytesCountPerChunk = Cipher.bytesCountPerChunk;
    benchmarkStatus
        .append('[Benchmark] ${Cipher.bytesCountPerChunk} bytes/chunk \n');
    for (int size in testedSizes) {
      var b = Uint8List(size * 1000000);
      csv += "${size * 1000000};";
      var cryptoTime = 0;

      // Encryption
      var before = DateTime.now();
      Object encryptedBigFile;
      if (usePc) {
        encryptedBigFile = pc.encrypt(b, state.secretKey.bytes);
      } else {
        encryptedBigFile = await cipher.encrypt(b, null);
      }
      var after = DateTime.now();

      var benchmark =
          after.millisecondsSinceEpoch - before.millisecondsSinceEpoch;
      benchmarkStatus.append('[$size MB] Encryption took $benchmark ms\n');

      csv += "$benchmark;";
      cryptoTime += benchmark;

      // Decryption
      before = DateTime.now();
      if (usePc) {
        pc.decrypt(encryptedBigFile as Uint8List, state.secretKey.bytes);
      } else {
        await cipher.decrypt(encryptedBigFile as CipherText);
      }
      after = DateTime.now();

      benchmark = after.millisecondsSinceEpoch - before.millisecondsSinceEpoch;
      benchmarkStatus.append('[$size MB] Decryption took $benchmark ms\n');

      csv += "$benchmark;";
      cryptoTime += benchmark;
      csv += "$cryptoTime\n";
    }
    var afterBench = DateTime.now();
    var benchmark =
        afterBench.millisecondsSinceEpoch - beforeBench.millisecondsSinceEpoch;
    var sum = testedSizes.reduce((a, b) => a + b);
    benchmarkStatus.append(
        'Benchmark finished.\nGenerated, encrypted and decrypted $sum MB in $benchmark ms');
    debugPrint("[Benchmark cvs]\n$csv");
  }

  void _clear() {
    benchmarkStatus.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Session state = ref.read(sessionProvider.state).state;
    if (state.secretKey.bytes.isEmpty) {
      keyContent
          .print('No SecretKey!\nGo in Key tab and generate or derive one.');
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Align(
                child: Text("Secret Key"),
                alignment: Alignment.centerLeft,
              ),
              keyContent,
            ],
          ),
        ),
      );
    }
    keyContent.print(state.secretKey.bytes.toString());

    AES cipher = AES(state.secretKey, AESMode.gcm);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Align(
              child: Text("Secret Key"),
              alignment: Alignment.centerLeft,
            ),
            keyContent,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button(
                      () => _benchmark(ref, cipher),
                      "NativeCrypto",
                    ),
                    Button(
                      () => _benchmark(ref, cipher, usePc: true),
                      "PointyCastle",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button(
                      () => _benchmarkEncryptionOnly(ref, cipher),
                      "NC Persistence",
                    ),
                    Button(
                      _clear,
                      "Clear",
                    ),
                  ],
                ),
              ],
            ),
            benchmarkStatus,
          ],
        ),
      ),
    );
  }
}
