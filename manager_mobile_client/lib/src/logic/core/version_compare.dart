
class Version {
  static int compare(String one, String other) {
    final oneComponents = one.split('.');
    final otherComponents = other.split('.');
    final oneMajor = int.parse(oneComponents[0]);
    final otherMajor = int.parse(otherComponents[0]);
    if (oneMajor != otherMajor) {
      return oneMajor - otherMajor;
    }
    final oneMinor = int.parse(oneComponents[1]);
    final otherMinor = int.parse(otherComponents[1]);
    if (oneMinor != otherMinor) {
      return oneMinor - otherMinor;
    }
    if (oneComponents.length < 3 || otherComponents.length < 3) {
      return oneComponents.length - otherComponents.length;
    }
    final onePatch = int.parse(oneComponents[2]);
    final otherPatch = int.parse(otherComponents[2]);
    return onePatch - otherPatch;
  }
}
