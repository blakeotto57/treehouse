import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  static const String secretKey = "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";
  static const String publishableKey = "pk_live_51QHBkvBXZFp1JN2DdxxjGMSu0araZivIpZSiOV8ZlWfUtTDjIXzWjR0mrrzhdnlIxf9A9Rjz8UJSoovzYgw1QfkP001opcNLtQ";

  /// Create a Stripe Checkout Session
  static Future<String?> createCheckoutSession(
      List<dynamic> productItems, double totalAmount) async {
    final Uri url = Uri.parse('https://api.stripe.com/v1/checkout/sessions');

    // Construct line items for the session
    String lineItems = "";
    int index = 0;

    for (var val in productItems) {
      final productPrice = (val["productPrice"] * 100).round().toString(); // Amount in cents
      lineItems +=
          "&line_items[$index][price_data][product_data][name]=${Uri.encodeComponent(val["productName"])}";
      lineItems += "&line_items[$index][price_data][unit_amount]=$productPrice";
      lineItems += "&line_items[$index][price_data][currency]=usd";
      lineItems += "&line_items[$index][quantity]=${val["qty"].toString()}";
      index++;
    }

    // Build the request body
    final String body =
        "success_url=https://checkout.stripe.dev/success&cancel_url=https://checkout.stripe.dev/cancel&mode=payment$lineItems";

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["url"]; // Return session URL
      } else {
        debugPrint("Stripe API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error creating Stripe session: $e");
      return null;
    }
  }
    /// Redirect the user to Stripe Checkout
  static Future<void> stripePaymentCheckout(
    List<dynamic> productItems,
    double subTotal,
    BuildContext context,
    bool mounted, {
    required VoidCallback onSuccess,
    required VoidCallback onCancel,
    required Function(String) onError,
  }) async {
    final String? sessionUrl = await createCheckoutSession(productItems, subTotal);

    if (sessionUrl == null) {
      onError("Failed to create Stripe Checkout session.");
      return;
    }

    try {
      final Uri url = Uri.parse(sessionUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        onSuccess();
      } else {
        onError("Could not launch the Stripe Checkout page.");
      }
    } catch (e) {
      onError("Stripe Checkout error: $e");
    }
  }
}