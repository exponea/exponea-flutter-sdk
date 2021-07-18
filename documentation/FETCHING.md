# Fetching data
Exponea SDK allows you to fetch data from Exponea backend, namely **Customer consents** and **Customer recommendations**.

## Customer consents
With customer consents you can define categories and base your application features/tracking based on customer's membership in those categories. More information can be found in [Exponea GDPR documentation](https://docs.exponea.com/docs/security-gdpr).

To fetch consents for the current customer, you can use `fetchConsents()` function:
```dart
import 'package:exponea/exponea.dart';

final _plugin = ExponeaPlugin();
_plugin.fetchConsents()
  .then((list) => list.forEach((consent) => print(consent)))
  .catchError((error) => print('Error: $error'));
```

## Customer recommendations
Exponea offers a machine learning engine providing product recommendations for for customers based on your data. You can read more about customer recommendations and how to setup your model in [Exponea Recommendations manual](https://docs.exponea.com/docs/recommendations).

To fetch recommendations for the current customer, use `fetchRecommendations()` function:

```dart
final options = RecommendationOptions(
  id: 'recommendation_id',
  fillWithRandom: true,
);
_plugin.fetchRecommendations(options)
  .then((list) => list.forEach((recommendation) => print(recommendation.itemId)))
  .catchError((error) => print('Error: $error'));
```