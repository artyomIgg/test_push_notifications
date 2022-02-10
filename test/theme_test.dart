import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_notifications/theme/cubit/theme_cubit.dart';
import 'package:weather_repository/weather_repository.dart';



// ignore: must_be_immutable
class MockWeather extends Mock implements Weather {
  MockWeather(this._condition);

  final WeatherCondition _condition;

  @override
  WeatherCondition get condition => _condition;
}

void main() {
  group('ThemeCubit', () {
    test('initial state is correct', () {
      mockHydratedStorage(() {
        expect(ThemeCubit().state, ThemeCubit.defaultColor);
      });
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        mockHydratedStorage(() {
          final themeCubit = ThemeCubit();
          expect(
            themeCubit.fromJson(themeCubit.toJson(themeCubit.state)),
            themeCubit.state,
          );
        });
      });
    });

    group('updateTheme', () {
      final clearWeather = MockWeather(WeatherCondition.clear);
      final snowyWeather = MockWeather(WeatherCondition.snowy);
      final cloudyWeather = MockWeather(WeatherCondition.cloudy);
      final rainyWeather = MockWeather(WeatherCondition.rainy);
      final unknownWeather = MockWeather(WeatherCondition.unknown);

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.clear',
        build: () => mockHydratedStorage(ThemeCubit.new),
        act: (cubit) => cubit.updateTheme(clearWeather),
        expect: () => <Color>[Colors.orangeAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.snowy',
        build: () => mockHydratedStorage(ThemeCubit.new),
        act: (cubit) => cubit.updateTheme(snowyWeather),
        expect: () => <Color>[Colors.lightBlueAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.cloudy',
        build: () => mockHydratedStorage(ThemeCubit.new),
        act: (cubit) => cubit.updateTheme(cloudyWeather),
        expect: () => <Color>[Colors.blueGrey],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.rainy',
        build: () => mockHydratedStorage(ThemeCubit.new),
        act: (cubit) => cubit.updateTheme(rainyWeather),
        expect: () => <Color>[Colors.indigoAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.unknown',
        build: () => mockHydratedStorage(ThemeCubit.new),
        act: (cubit) => cubit.updateTheme(unknownWeather),
        expect: () => <Color>[ThemeCubit.defaultColor],
      );
    });
  });
}